
internal class CharRule : Rule {
	private		|Int?->Bool|	func
	override	Str				expression
	
	new make(Str expression, |Int->Bool| func) {
		this.func = |Int? peek->Bool| { (peek == null) ? false : func(peek) }
		this.expression = expression
	}

	override Bool doProcess(PegCtx ctx) {
		peek := ctx.readChar
		ctx.matched(peek?.toChar)
		return func(peek)
	}
}

internal class StrRule : Rule {
	private		Str				str
	private		Bool			ignoreCase
	override	Str				expression
	
	new make(Str str, Bool ignoreCase) {
		this.str	 	= str
		this.ignoreCase	= ignoreCase
		this.expression = str.toCode
	}

	override Bool doProcess(PegCtx ctx) {
		peek := ctx.read(str.size)
		ctx.matched(peek)
		return ignoreCase ? str.equalsIgnoreCase(peek ?: Str.defVal) : str.equals(peek)
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

		ctx.matched(matched.toStr)

		return !matched.isEmpty
	}
}
