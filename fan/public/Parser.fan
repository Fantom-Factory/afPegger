
class Parser {
	private Rule 		rootRule
	
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}
	
	Str? parse(InStream in) {
		ctx		:= PegCtx(rootRule, in)
		result	:= ctx.process(rootRule)
		if (result)
			ctx.rootResult.success
		return result ? ctx.rootResult.matched : null
	}
}
