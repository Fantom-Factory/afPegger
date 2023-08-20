
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

	** Returns 'true' if a there's a direct sub-match with the given rule name or label.
	Bool contains(Str name) {
		getMatch(name) != null
	}
	
	** Returns the first direct sub-match with the given rule name (or label).
	@Operator
	Match? getMatch(Str name) {
		result.findMatch(name, in)
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

	** Returns all direct sub-mataches.
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
