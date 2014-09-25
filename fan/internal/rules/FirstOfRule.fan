
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Bool doProcess(PegCtx ctx) {
		rules.any |Rule rule->Bool| {
			ctx.process(rule)
		}		
	}

	override This add(Rule rule) {
		rules.add(rule)
		return this
	}

	override Str expression() {
		"(" + rules.join(" / ") + ")"
	}
}
