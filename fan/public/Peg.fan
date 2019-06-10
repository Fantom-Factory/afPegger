
// TODO Peg Methods
** 
** pegMatch.walk |???| {  }
** 
@Js
class Peg {
	private PegCtx	pegCtx
	private Rule	rule
	
	** Creates a PEG class ready to match the given string with the given rule.
	new make(Str str, Rule rule) {
		this.rule	= rule
		this.pegCtx	= PegCtx(str, rule)
	}

	** Parses the given PEG pattern in to a rule.
	** Convenience for:
	** 
	**   syntax: fantom 
	**   Peg(str, Peg.parsePattern(pattern))
	new makePattern(Str str, Str pattern) {
		this.rule	= Peg.parseRule(pattern)
		this.pegCtx	= PegCtx(str, rule)
	}

	// ---- Static methods ----
	
	** Turns debug messaging on and off.
	static Void debugOn(Bool debug := true) {
		Peg#.pod.log.level = debug ? LogLevel.debug : LogLevel.info
	}
	
	** Parses a pattern in to simple rule.
	** For example:
	** 
	**   syntax: fantom 
	**   parseRule("[abc] / [xyz]")
	static Rule parseRule(Str pattern) {
		PegGrammar().parseRule(pattern)
	}
	
	** Parses grammar definitions, and returns the root rule (if given) or the first rule parsed.
	** For example:
	** 
	**   syntax: fantom 
	**   parseGrammar("a <- [abc] / [xyz] / b
	**                 b <- \space+ [^abc]")
	static Grammar parseGrammar(Str grammar) {
		PegGrammar().parseGrammar(grammar)
	}
	
	** Returns the grammar PEG uses to parse PEG grammar.
	** 
	** It's not particularly useful, but it may be interesting to some.
	static Grammar pegGrammar() {
		PegGrammar.pegGrammar
	}
	
	// ---- Instance methods ----

	// FIXME Int startOffset
	** Searches for the next match and returns the matched string (if any).
	Str? search() {
		c := pegCtx.cur
		m := null as Match
		while (m == null && !pegCtx.eos) {
			m = match
			if (m == null)
				pegCtx.rollbackTo(++c)
		}
		return m?.matched
	}

	** Returns 'true' if the string contains a rule match.
	** Convenience for: 
	**   search != null
	Bool contains() {
		search != null
	}
	
	// TODO replace()
//	Str replace(Str replacePattern, Int startOffset := 0) { "" } // replace("Steve \2{backRef}")
//	Str replaceAll(Str replacePattern) { "" }
	
//	Str replaceFn(Str replacePattern) |PegMatch m -> Str| { "" }
//	Str replaceAllFn(Str replacePattern) |PegMatch m -> Str| { "" }
	
	** Runs the PEG rule against the string.
	Match? match() {
		pegCtx.clearResults.process(rule)
			? pegCtx.doSuccess
			: null
	}
	
	** Runs the PEG rule against the string.
	** Returns 'true' if it matches.
	Bool matches() {
		match != null
	}
	
	** Runs the PEG rule against the string.
	** Returns the matched string.
	Str? matched() {
		match?.matched
	}
	
	** Calls the given function for each rule match found in the string.
	Void each(|Match| fn) {
		m := match
		while (m != null) {
			fn(m)
			m = match
		}
	}

	** Calls the given function for each rule match found, until a non-null result is returned.
	** If there are no matches, null is returned.
	Obj? eachWhile(|Match->Obj?| fn) {
		r := null
		m := match
		while (m != null && r == null) {
			r = fn(m)
			if (r == null)
				m = match
		}
		return r
	}
}
