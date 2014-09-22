
internal class StrRule : Rule {
	private		|Str->Bool|	func
	private		Int			strSize
	override	Str			desc
	
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

	override Result walk(PegInStream in) {
		result	:= Result(name) 

		peek 	:= in.read(strSize)
		matched := func(peek)

		if (!matched) {
			result.failed(name, "$desc != $peek")
			in.unread(peek?.size ?: 0)
		}

		if (matched) {
			result.matchStr = peek
			result.successFunc	= |->| { action?.call(result) } 
			result.rollbackFunc	= |->| { in.unread(peek?.size ?: 0) }
			result.passed(name, desc)
		}

		return result
	}
}
