
// TODO Peg Methods
** Peg.parseRule("...")
** Peg.parseGrammar("...", <rootRuleName>)
** 
** Peg("str", "...").replace("Steve \2{backRef}")
** Peg("str", "...").replaceAll("...")
** 
** pegMatch.walk |???| {  }
** 
@Js class Peg {
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
		this.rule	= Peg.parsePattern(pattern)
		this.pegCtx	= PegCtx(str, rule)
	}

	** Turns debug messaging on and off.
	static Void debugOn(Bool debug := true) {
		Peg#.pod.log.level = debug ? LogLevel.debug : LogLevel.info
	}
	
	** Parses a pattern in to simple rule.
	** For example:
	** 
	**   syntax: fantom 
	**   parseRule("[abc] / [xyz]")
	static Rule parsePattern(Str pattern) {
		PegGrammar().parsePattern(pattern)
	}
	
	** Parses grammar definitions, and returns the root rule (if given) or the first rule parsed.
	** For example:
	** 
	**   syntax: fantom 
	**   parseGrammar("a <- [abc] / [xyz] / b
	**                 b <- \space+ [^abc]")
	static Rule[] parseGrammar(Str grammar) {
		PegGrammar().parseGrammar(grammar)
	}
	
	// FIXME Int startOffset
	** Searches for the next match and returns the matched string (if any).
	Str? search() {
		c := pegCtx.cur
		m := null as PegMatch
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
//	Str replace(Str replacePattern, Int startOffset := 0) { "" }
//	Str replaceAll(Str replacePattern) { "" }
	
//	Str replaceFn(Str replacePattern) |PegMatch m -> Str| { "" }
//	Str replaceAllFn(Str replacePattern) |PegMatch m -> Str| { "" }
	
	** Runs the PEG rule against the string.
	PegMatch? match() {
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
	Void each(|PegMatch| fn) {
		m := match
		while (m != null) {
			fn(m)
			m = match
		}
	}

	** Calls the given function for each rule match found, until a non-null result is returned.
	** If there are no matches, null is returned.
	Obj? eachWhile(|PegMatch->Obj?| fn) {
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
