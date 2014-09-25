
internal class StrRule : Rule {
	private		|Str?->Bool|	func
	private		Int				peekSize
	override	Str				expression
	
	new makeFromCharFunc(Str expression, |Int->Bool| func) {
		this.func = |Str? peek->Bool| { (peek == null || peek.isEmpty) ? false : func(peek.chars.first) }
		this.expression = expression
		this.peekSize = 1
	}

	new makeFromStrFunc(Str expression, Int peekSize, |Str?->Bool| func) {
		this.func = func
		this.expression = expression
		this.peekSize = peekSize
	}

	override Bool doProcess(PegCtx ctx) {
		peek := ctx.read(peekSize)
		ctx.matched = peek
		return func(peek)
	}
}

internal class StrNotRule : Rule {
	private		Str		str
	private		Bool	ignoreCase
	override	Str		expression
	
	new makeFromStrFunc(Str str, Bool ignoreCase) {
		this.str = str
		this.ignoreCase = ignoreCase
		this.expression = "(!${str.toCode} .)+"
	}

	override Bool doProcess(PegCtx ctx) {
		matched 	:= StrBuf(256)
		keepGoing	:= true
		while (keepGoing) {
			// FIXME: optomise
			peek 	:= ctx.read(str.size)
			if (peek == null || peek.isEmpty || (ignoreCase ? str.equalsIgnoreCase(peek) : str.equals(peek))) {
				keepGoing = false
				ctx.unread(peek)
			} else {
				matched.addChar(peek[0])
				ctx.unread(peek[1..-1])
			}
		}

		ctx.matched = matched.toStr

		return !matched.isEmpty
	}
}
