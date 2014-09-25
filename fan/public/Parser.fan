
** The main parser class; use to run your rules against an 'InStream'. 
class Parser {
	private Rule 		rootRule
	
	** Create a 'Parser' with the given root 'Rule'.
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}
	
	** Runs the parsing rules against the characters in the given 'InStream'.
	Str? parse(InStream in) {
		ctx		:= PegCtx(rootRule, in)
		result	:= ctx.process(rootRule)
		if (result)
			ctx.rootResult.success
		return result ? ctx.rootResult.matched : null
	}
}
