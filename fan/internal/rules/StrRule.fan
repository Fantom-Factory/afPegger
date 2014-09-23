
internal class StrRule : Rule {
	private		|Str?->Bool|	func
	private		Int				strSize
	override	Str				desc
	
	new makeFromCharFunc(Str desc, |Int->Bool| func) {
		this.func = |Str? peek->Bool| { peek == null ? false : func(peek.chars.first) }
		this.desc = desc
		this.strSize = 1
	}

	new makeFromStrFunc(Str desc, |Str?->Bool| func) {
		this.func = func
		this.desc = desc
		this.strSize = desc.size
	}

	override Void doProcess(PegCtx ctx) {
		peek 	:= ctx.read(strSize)
		matched := func(peek)

		ctx.rollbackFunc = |->| { ctx.unread(peek) }

		if (matched) 
			ctx.matched = peek

		ctx.pass(matched)
	}
}
