
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

	override Str desc() {
		"(" + rules.join(" / ") { it.name ?: it.desc } + ")"
	}
}
