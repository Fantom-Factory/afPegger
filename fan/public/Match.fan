
** Represents a PEG match result.
@Js
class Match {
	private Result	result
	private Str		in
	
	** Storage for user data - use when investigating match results.
	[Str:Obj?]?		data
	
	internal new make(Result result, Str in) {
		this.result = result
		this.in		= in
	}

	** Returns the associated rule 'label' (or 'name' if 'label' is 'null').
	Str? name() {
		rule.label ?: rule.name
	}

	// Meh, it's too complicated distinguishing between the two in switch statements (see HTML parser)
	// much easy to munge the two into "name" - users can always query the Rule if need be 
//	** Returns the associated rule label, or name if there is no label.
//	Str? label() {
//		rule.label ?: rule.name
//	}

	** Returns 'true' if a there's a direct sub-match with the given rule label or name.
	Bool contains(Str label) {
		getMatch(label) != null
	}
	
	** Deeply searches for a labelled Match of the given name at the given index.
	** 
	** Negative indexes can not be used.
	Match? findMatch(Str label, Int index := 0) {
		if (this.name == label)
			return this

		i := 0
		return matches.eachWhile |match| {
			gotOne := match.findMatch(label)
			
			// keep counting until we find the match at the given index 
			if (gotOne != null && i++ < index)
				gotOne = null

			return gotOne
		}
	}
	
	** Returns the direct sub-match with the given label (or rule name) at the given index.
	** 
	** Use negative index to access from the end of the list.
	@Operator
	Match? getMatch(Str label) {
		result.getMatch(label, in)
	}

	** Returns the direct sub-match at the given index.
	@Operator
	Match? getMatchAt(Int index) {
		matches[index]
	}
	
	** Returns the first direct sub-match.
	Match? firstMatch() {
		matches.first
	}

	** Returns all direct sub-matches, optionally with the given label / name.
	Match[] matches(Str? label := null) {
		label == null ? result.matches(in) : result.getMatches(label, in)
	}
	
	** Returns the matched string.
	Str matched() {
		result.matchedStr(in)
	}
	
	** Returns the matched range; where this match lies within the input string.
	Range matchedRange() {
		result.matchedRange(in)
	}
	
	** Returns a snippet of source code, centred on this match.
	Str snippet(Str? msg := null, Int? padding := null) {
		result.matchedSnippet(in, msg, padding)
	}
	
	** Returns the '[x,y]' character location of this match in the input string. 
	** Coordinates are one-based.
	Int[] location() {
		result.matchedLocation(in)
	}
	
	** Returns the line number of this match in the input string.
	** Number is one-based. 
	Int lineNum() {
		result.matchedLineNum(in)
	}

	** Returns the parent Match in the tree, or 'null' if this is the root.
	Match? parent() {
		result.parent?.match(null, in)	// null is fine, as we've already set the parent
	}
	
	** Returns the rule associated with this match.
	Rule rule() {
		result.rule
	}
	
	** Dumps the matched tree to std-out.
	** Useful for debugging.
	This dump(OutStream out := Env.cur.out) {
		out.printLine(debugStr)
		return this
	}

	** Returns the matched tree as a string.
	Str debugStr() {
		buf := StrBuf(in.size * 5)
		doDump(buf, Bool[,])
		return buf.toStr
	}
	
	** Returns any user-defined meta set by the matching Rule.
	Obj? meta() {
		result.meta
	}

	// Meh - I don't actually like this - and it's often easier to just itr over the matches yourself
//	** Walks the match tree, calling the given funcs as it steps in to, and out of, a 'Match'.
//	** Start with *this* 'Match'. 
//	Void walk(|Match|? start, |Match|? end) {
//		start?.call(this)
//		matches.each { it.walk(start, end) }
//		end?.call(this)
//	}
	
	@NoDoc
	override Str toStr() { matched }
	
	// chars from `https://atom.io/packages/ascii-tree`
	private Void doDump(StrBuf buf, Bool[] indent) {
		// tidy up dumps, so we exclude names (in special cases)
		ruleName := rule is RuleRef && rule->realRule->useInResult == false ? null : rule.name
		
		name := [rule.label, ruleName].exclude { it == null }.join(":").trimToNull ?: "???:???"
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
