
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Void doProcess(PegCtx ctx) {
		passed := rules.all |Rule rule->Bool| {
			pass := ctx.process(rule)
			if (!pass)
				ctx.log("Did not match ${rule.desc}")
			return pass
		}
		
		ctx.pass(passed)
	}

	override Str desc() {
		rules.join(" ") { it.name ?: it.desc }
	}
}