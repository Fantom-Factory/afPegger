
internal class StrRule : Rule {
	private Str	str
	
	new make(Str str) {
		this.str = str
	}
	
	override Result walk(PegCtx ctx) {
		result	:= Result(name) 

		matched := ctx.matchStr(str.size) |peek->Bool| { peek == str }

		if (matched == null)
			ctx.unread(str.size)
		
		if (matched != null) { 
			result.matchStr = matched
			result.success	= |->| { action?.call(result) } 
			result.rollback	= |->| { ctx.unread(str.size) }
		}
		
		return result
	}
	
	override Str desc() {
		str.toCode
	}
}




