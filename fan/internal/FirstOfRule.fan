
internal class FirstOfRule : Rule {
	private Rule[]	rules
	private Rule?	matched
	private Match?	matcha
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override internal Match? match(PegCtx ctx) {
		failureCap := ctx.fails.size

		matcha = null
		matched = rules.find |rule->Bool| {
			matcha = rule.match(ctx)
			return (matcha != null)
		}

		if (matcha != null)
			ctx.fails.size = failureCap			

		return matcha
	}
	
	override internal Void rollback(PegCtx ctx) {
		matched?.rollback(ctx)
	}

	override internal Void walk(Match match) {
		matched.walk(matcha)
		action?.call(match)
	}

	override Str desc() {
		"(" + rules.join(" / ") + ")"
	}
	
	override This dup() { 
		FirstOfRule(rules.map { it.dup }) { it.name = this.name; it.action = this.action }
	} 
}