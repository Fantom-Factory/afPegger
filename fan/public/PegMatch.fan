
@Js class PegMatch {
	
	private Result	result
	private Str		in
	
	internal new make(Result result, Str in) {
		this.result = result
		this.in		= in
	}

	Str? name() {
		rule.name
	}

	@Operator
	PegMatch? get(Str name, Bool checked := true) {
		result.findResult(name)?.match(in) ?: (checked ? throw Err("Could not find node: $name") : null)
	}
	
	PegMatch[] matches() {
		result.matches(in)
	}
	
	Str matched() {
		result.matchedStr(in)
	}
	
	Range matchedRange() {
		result.matchedRange(in)
	}

	Rule rule() {
		result.rule
	}
	
	This dump() {
		echo(dumpToStr)
		return this
	}
	
	Str dumpToStr() {
		buf := StrBuf(in.size * 5)
		doDump(buf, 0)
		return buf.toStr
	}
	
	// chars from `https://atom.io/packages/ascii-tree`
	private Void doDump(StrBuf buf, Int indent) {
//		for (i := 0; i < indent * 4; ++i) { buf.addChar(' ') }
		
		buf.add(name ?: rule.expression)
		matches := matches

		if (matches.isEmpty)
			buf.addChar(' ').addChar(':').addChar(' ').add(matched.toCode)
		buf.addChar('\n')

		matches.each |match, i| {
			for (x := 0; x < indent * 4; ++x) { buf.addChar(' ') }
			buf.addChar(matches.size-1 == i ? '└' : '├').addChar('─').addChar(' ')
			match.doDump(buf, indent + 1)
		}
	}
}
