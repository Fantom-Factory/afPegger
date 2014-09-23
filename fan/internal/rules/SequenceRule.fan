
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Void doProcess(PegCtx ctx) {
		passed := rules.all |Rule rule->Bool| {
			ctx.process(rule)
		}
		
		ctx.pass(passed)
	}

	override Str desc() {
		"(" + rules.join(" ") { it.name ?: it.desc } + ")"
	}
}