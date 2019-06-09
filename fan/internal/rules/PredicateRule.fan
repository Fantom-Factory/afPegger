
@Js
internal class PredicateRule : Rule {
	private Rule rule
	private Bool not
	
	new make(Rule rule, Bool not) {
		this.rule	= rule
		this.not	= not
	}
	
	override Bool doProcess(PegCtx ctx) {
		start  := ctx.cur
		passed := not ? !ctx.process(rule) : ctx.process(rule)
		if (passed) {
			ctx.log("Rolling back predicate")
			ctx.rollbackTo(start)
		}
		return passed
	}

	override Str expression() {
		(not ? "!" : "&") + rule._dis
	}
}
