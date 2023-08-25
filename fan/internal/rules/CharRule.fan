
** This is its own rule class to override the expression
@Js
internal class AnyCharRule : Rule {
	override Str _expression	:= "."	
	override Bool doProcess(RuleCtx ctx) {
		ctx.readChar != 0
	}
}

** This is its own rule class to override the expression
@Js
internal class StrMimickCharRule : Rule {
	private const Int	char
	private const Bool	ignoresCase

	new make(Int char, Bool caseInsensitive) {
		this.char		 = char
		this.ignoresCase = caseInsensitive
	}

	override Bool doProcess(RuleCtx ctx) {
		peek := ctx.readChar
		pass := peek == char
		if (!pass && ignoresCase) {
			peek = peek.isLower ? peek.upper : peek.lower
			pass = peek == char
		}
		return pass
	}

	override Str _expression() {
		char.toChar.toCode + (ignoresCase ? "i" : "")
	}
	
	override Str typeName() {
		"charRule"
	}
}

@Js
internal class CharRule : Rule {
	// todo immutable funcs not allowed in JS!
	private			 |Int->Bool|	func
	private		const Bool			not
	private		const Str			express
	internal		  Bool			ignoresCase

	new make(Str expression, Bool not, |Int->Bool| func) {
		this.func 	 = func
		this.express = expression
		this.not	 = not
	}

	static Rule fromStr(Str charClass) {
		cClass := StrBuf(charClass.size).add(charClass)
		ignore := cClass[-1] == 'i'
		if (ignore) cClass.remove(-1)

		if (cClass[0] != '[' && cClass[-1] != ']')
			throw ParseErr("Invalid Char class: $charClass")
		cClass.remove(0).remove(-1)
		
		not := cClass[0] == '^'
		if (not) cClass.remove(0)

		try {
			chars  := Int[,]
			ranges := Range[,]
			while (cClass.size > 0) {
				start := chomp(cClass)
				end   := cClass.isEmpty ? null : cClass[0]
		
				if (end == '-') {
					cClass.remove(0)
					end = chomp(cClass)
					ranges.add(start..end)

				} else
					chars.add(start)
			}
			
			if (ranges.isEmpty && chars.size == 1 && !not)
				return StrMimickCharRule(chars.first, ignore)

			express := ranges.join("") { it.start.toChar + "-" + it.end.toChar }.toCode(null, true) + chars.join("") { it.toChar }.toCode(null, true).replace("]", "\\]").replace("-", "\\-") 
			return CharRule(express, not) |Int peek->Bool| {
				fn := chars.contains(peek) || ranges.any { it.contains(peek) }
				if (!fn && ignore) {
					peek = peek.isLower ? peek.upper : peek.lower
					fn   = chars.contains(peek) || ranges.any { it.contains(peek) }
				}
				return fn
			} { it.ignoresCase = ignore }
	
		} catch throw ParseErr("Invalid Char class: $charClass")
	}
	
	override Bool doProcess(RuleCtx ctx) {
		if (ctx.eos) return false
		res := func(ctx.readChar)
		return not ? !res : res
	}
	
	override Str _expression() {
		"[" + (not ? "^" : "") + express + "]" + (ignoresCase ? "i" : "")
	}
	
	private static Int chomp(StrBuf str) {
		char := str[0]; str.remove(0)
	
		if (char == '\\') {
			// this allows ALL chars to be escaped
			char = str[0]; str.remove(0)
			if (char == '\\')	char = '\\'; else
			if (char == 'b')	char = '\b'; else
			if (char == 'f')	char = '\f'; else
			if (char == 'n')	char = '\n'; else
			if (char == 'r')	char = '\r'; else
			if (char == 't')	char = '\t'; else
			if (char == 'u')	char = unicode(str)
		}
		return char
	}
	
	private static Int unicode(StrBuf str) {
		hex := str[0..<4]
		str.removeRange(0..<4)
		return Int.fromStr(hex, 16)
	}
}
