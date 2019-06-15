
@Js
internal class PredicateRule : Rule {
	private Rule rule
	private Bool not
	
	new make(Rule rule, Bool not) {
		this.rule	= rule
		this.not	= not
	}
	
	override Bool doProcess(RuleCtx ctx) {
		start  := ctx.currentPos
		passed := not ? !ctx.process(rule) : ctx.process(rule)
		if (passed) {
			ctx.log("Rolling back predicate")
			ctx.rollbackToPos(start)
		}
		return passed
	}

	override Str expression() {
		(not ? "!" : "&") + rule._dis(true)
	}
}
