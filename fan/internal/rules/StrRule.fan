
internal class StrRule : Rule {
	private		|Str?->Bool|	func
	private		Int				peekSize
	override	Str				desc
	
	new makeFromCharFunc(Str desc, |Int->Bool| func) {
		this.func = |Str? peek->Bool| { peek == null ? false : func(peek.chars.first) }
		this.desc = desc
		this.peekSize = 1
	}

	new makeFromStrFunc(Str desc, Int peekSize, |Str?->Bool| func) {
		this.func = func
		this.desc = desc
		this.peekSize = peekSize
	}

	override Void doProcess(PegCtx ctx) {
		peek 	:= ctx.read(peekSize)
		matched := func(peek)

		ctx.rollbackFunc = |->| { ctx.unread(peek) }

		if (matched) 
			ctx.matched = peek

		ctx.pass(matched)
	}
}

internal class StrNotRule : Rule {
	private		Str		str
	private		Bool	ignoreCase
	override	Str		desc
	
	new makeFromStrFunc(Str str, Bool ignoreCase) {
		this.str = str
		this.ignoreCase = ignoreCase
		this.desc = "(!${str.toCode} .)+"
	}

	override Void doProcess(PegCtx ctx) {
		matched 	:= Str.defVal
		keepGoing	:= true
		while (keepGoing) {
			peek 	:= ctx.read(str.size)
			if (peek == null || peek.isEmpty || (ignoreCase ? str.equalsIgnoreCase(peek) : str.equals(peek))) {
				keepGoing = false
				ctx.unread(peek)
			} else {
				matched += peek[0].toChar
				ctx.unread(peek[1..-1])
			}
		}

		ctx.rollbackFunc = |->| { ctx.unread(matched) }

		if (!matched.isEmpty)
			ctx.matched = matched

		ctx.pass(!matched.isEmpty)
	}
}
