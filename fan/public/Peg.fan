
// TODO Peg Methods
** Peg.parseRule("...")
** Peg.parseGrammar("...", <rootRuleName>)
** 
** Peg("str", rule).search
** Peg("str", "...").search  -> str match

** Peg("str", "...").replace("Steve \2{backRef}")
** Peg("str", "...").replaceAll("...")
** 
** Peg("str", "...").contains -> bool
** 
** Peg("str", "...").each |match| { ... }
** 
** Peg("str", "...").Find |match->Obj?| { ... }
** Peg("str", "...").eachWhile |match->Obj?| { ... }
** 
** 
** Match.walk
** 
@Js class Peg {
	private Str		str
	private Rule	rule
	private PegCtx	pegCtx
	
	new make(Str str, Rule rule) {
		this.str	= str
		this.rule	= rule
		this.pegCtx	= PegCtx(rule, str)
	}
	
//	new make(Str str, Str pattern) {
//		this.str	= str
//		this.rule	= PegGrammar.parse(pattern)		
//	}
	
//	Str find() { "" }	.. search?
//	Str replace(Str replacePattern, Int index := 0) { "" }
//	Str replaceAll(Str replacePattern) { "" }
//	Bool contains() { false }	// like find
	
	** Runs the PEG rule against the string.
	PegMatch? match() {
		pegCtx.process(rule)
			? pegCtx.doSuccess(null)
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
}
