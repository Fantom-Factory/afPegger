
internal class StrRule : Rule {
	override Str? name
	private Str str
	
	new make(Str str) {
		this.str = str
	}
	
	override internal Bool matches(PegBuf buf) {
		buf.read(str.size) == str
	}
	
	override internal Match pass(PegBuf buf) {
		Match(name, str)
	}

	override internal Void fail(PegBuf buf) {
		buf.unread(str.size)
	}
}

internal class InRangeRule : Rule {
	override Str?	name
	private Range	charRange
	private Int?	matched
	
	new make(Range charRange) {
		this.charRange = charRange
	}
	
	override internal Bool matches(PegBuf buf) {
		matched = buf.readChar
		return charRange.contains(matched)
	}
	
	override internal Match pass(PegBuf buf) {
		Match(name, matched.toChar)
	}

	override internal Void fail(PegBuf buf) {
		buf.unread(1)
	}
}
