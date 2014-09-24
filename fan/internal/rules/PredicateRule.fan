
internal class PredicateRule : Rule {
	private Rule rule
	private Bool not
	
	new make(Rule rule, Bool not) {
		this.rule	= rule
		this.not	= not
	}
	
	override Void doProcess(PegCtx ctx) {
		passed := not ? !ctx.process(rule) : ctx.process(rule)
		ctx.rollback("Rolling back predicate")
		ctx.pass(passed)
	}

	override Str expression() {
		(not ? "!" : "&") + wrapRuleName(rule) 
	}
}
