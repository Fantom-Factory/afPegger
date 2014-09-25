
internal class PredicateRule : Rule {
	private Rule rule
	private Bool not
	
	new make(Rule rule, Bool not) {
		this.rule	= rule
		this.not	= not
	}
	
	override Bool doProcess(PegCtx ctx) {
		passed := not ? !ctx.process(rule) : ctx.process(rule)
		ctx.rollback("Rolling back predicate")
		return passed
	}

	override Str expression() {
		(not ? "!" : "&") + wrapRuleName(rule) 
	}
}
