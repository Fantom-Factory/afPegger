
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Void doProcess(PegCtx ctx) {
		passed := rules.any |Rule rule->Bool| {
			ctx.process(rule)
		}		
		ctx.pass(passed)
	}

	override This add(Rule rule) {
		rules.add(rule)
		return this
	}

	override Str expression() {
		"(" + rules.join(" / ") + ")"
	}
}
