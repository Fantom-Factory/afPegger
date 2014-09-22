
internal class StrRule : Rule {
	private		|Str->Bool|	func
	private		Int			strSize
	override	Str			desc
	
	new makeFromCharFunc(Str desc, |Int->Bool| func) {
		this.func = |Str? peek->Bool| { peek == null ? false : func(peek.chars.first) }
		this.desc = desc
		this.strSize = 1
	}

	new makeFromStrFunc(Str str, Bool caseInsensitive) {
		this.desc = str
		this.func = |Str? peek->Bool| { caseInsensitive ? str.equalsIgnoreCase(peek) : str.equals(peek) }
		this.strSize = str.size
	}

	override Result walk(PegCtx ctx) {
		result	:= Result(name) 

		peek 	:= ctx.read(strSize)
		matched := func(peek)

		if (!matched) {
			result.failed(name, "$desc != peek")
			ctx.unread(peek?.size ?: 0)
		}

		if (matched) {
			result.matchStr = peek
			result.successFunc	= |->| { action?.call(result) } 
			result.rollbackFunc	= |->| { ctx.unread(peek?.size ?: 0) }
			result.passed(name, desc)
		}

		return result
	}
}
