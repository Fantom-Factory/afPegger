
internal class CharRule : Rule {
	private  |Int->Bool|	func
	private  Str			str
	
	new make(Str str, |Int peek->Bool| func) {
		this.str  = str
		this.func = func
	}

	override Result walk(PegCtx ctx) {
		result	:= Result(name) 

		matched := ctx.matchStr(1) |peek->Bool| { func(peek.chars.first) }

		if (matched == null) {
			ctx.unread(1)
		}

		if (matched != null) { 
			result.matchStr = matched
			result.success	= |->| { action?.call(result) } 
			result.rollback	= |->| { ctx.unread(1) }
		}

		return result
	}

	override Str desc() {
		str
	}
}
