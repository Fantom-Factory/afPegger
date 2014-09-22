
internal class StrRule : Rule {
	private		|Str->Bool|	func
	private		Int			strSize
	override	Str			desc
	
	new makeFromCharFunc(Str desc, |Int->Bool| func) {
		this.func = |Str peek->Bool| { func(peek.chars.first) }
		this.desc = desc
		this.strSize = 1
	}

	new makeFromStrFunc(Str str, Bool caseInsensitive) {
		this.desc = str
		this.func = |Str peek->Bool| { caseInsensitive ? peek.equalsIgnoreCase(str) : peek.equals(str) }
		this.strSize = str.size
	}

	override Result walk(PegCtx ctx) {
		result	:= Result(name) 

		matched := ctx.matchStr(strSize, func)

		if (matched == null) {
			if (name == null)
				result.debug(" - did not match $desc")
			else
				result.debug("'$name' did not match $desc")
			ctx.unread(strSize)
		}

		if (matched != null) {
			if (name == null)
				result.debug(" - matched '$desc'")
			else
				result.info("'$name' matched '$desc'")

			result.matchStr = matched
			result.successFunc	= |->| { action?.call(result) } 
			result.rollbackFunc	= |->| { ctx.unread(strSize) }
		}

		return result
	}
}
