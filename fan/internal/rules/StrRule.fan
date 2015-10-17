
@Js
internal class CharRule : Rule {
	private		|Int?->Bool|	func
	override	Str				expression
	
	new make(Str expression, |Int->Bool| func) {
		this.func = |Int? peek->Bool| { (peek == null) ? false : func(peek) }
		this.expression = expression
	}

	override Bool doProcess(PegCtx ctx) {
		peek := ctx.readChar
		ctx.matched = peek?.toChar
		return func(peek)
	}
}

@Js
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
		peek := ctx.readStr(str.size)
		ctx.matched = peek
		return ignoreCase ? str.equalsIgnoreCase(peek ?: Str.defVal) : str.equals(peek)
	}
}

@Js
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
		matched	:= Str.defVal
		
		// if we read too much, then we'll just have to unread it all on a no-match!
		toRead	:= str.size + 1
		
		keepGoing := true
		while (keepGoing) {
			peek := ctx.readStr(toRead)
			
			i := ignoreCase ? peek.indexIgnoreCase(str) : peek.index(str)
			if (i != null) {
				keepGoing = false
				if (i == 0) {
					ctx.unreadStr(peek)					
				} else {
					matched += peek[0..<i]
					ctx.unreadStr(peek[i..-1])
				}

			} else {
				if (peek.size < toRead) {
					// oops - ran out of piggies!
					keepGoing = false
					matched += peek
				} else {
					i = toRead - str.size
					matched += peek[0..<i]
					ctx.unreadStr(peek[i..-1])
					toRead = toRead * 2
				}
			}
		}

		ctx.matched = matched

		return !matched.isEmpty
	}
}
