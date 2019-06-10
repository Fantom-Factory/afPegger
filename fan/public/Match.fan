
** Represents a PEG match result.
@Js
class Match {
	
	private Result	result
	private Str		in
	
	internal new make(Result result, Str in) {
		this.result = result
		this.in		= in
	}

	** Returns the associated rule name
	Str? name() {
		rule.name
	}

	** Returns the first match with the given rule name.
	@Operator
	Match? getMatch(Str name) {
		result.findMatch(name, in)
	}
	
//	** Returns the matched group at the given index.
//	@Operator
//	Str? getGroup(Int groupNum) {
//		// TODO PegMatch.getGroup(Int) -> keyValPair <-- \s* {\w+} \s* '=' \s* {\w+}
//		throw UnsupportedErr()
//	}
	
	** Returns the first match.
	@NoDoc	// I'm not sure I like this name - I may delete it...?
	Match match() {
		matches.first
	}

	** Returns all sub-mataches.
	Match[] matches() {
		result.matches(in)
	}
	
	** Returns the matched string.
	Str matched() {
		result.matchedStr(in)
	}
	
	** Returns the matched range.
	Range matchedRange() {
		result.matchedRange(in)
	}

	** Returns the rule associated with this match.
	Rule rule() {
		result.rule
	}
	
	** Dumps the matched tree to std-out.
	This dump() {
		echo(dumpToStr)
		return this
	}
	
	** Returns the matched tree as a string.
	Str dumpToStr() {
		buf := StrBuf(in.size * 5)
		doDump(buf, Bool[,])
		return buf.toStr
	}

	// FIXME
//	Void walk(|Match| start, |Match| end) {
//		
//	}
	
	// chars from `https://atom.io/packages/ascii-tree`
	private Void doDump(StrBuf buf, Bool[] indent) {
		buf.add(name ?: rule.expression)
		matches := matches

		if (matches.isEmpty)
			buf.addChar(' ').addChar(':').addChar(' ').add(matched.toCode)
		buf.addChar('\n')

		matches.each |match, x| {
			indent.each { buf.addChar(' ').addChar(it ? '│' : ' ').addChar(' ').addChar(' ') }

			buf.addChar(' ').addChar(matches.size-1 == x ? '└' : '├').addChar('─').addChar(' ')
			
			indent.push(x != matches.size-1)
			match.doDump(buf, indent)
			indent.pop
		}
	}
}
