
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override internal Match? match(PegCtx ctx) {
		failureCap := ctx.fails.size

		// FIXME eachwhile
		matcha  := null
		matched := rules.find |rule->Bool| {
			matcha = rule.match(ctx)
			return (matcha != null)
		}

		if (matcha != null)
			ctx.fails.size = failureCap			

		ctx.stack.push(FirstOfRuleCtx { it.matched = matched; it.matcha = matcha })
		
		return matcha
	}
	
	override internal Void rollback(PegCtx ctx) {
		mctx := (FirstOfRuleCtx) ctx.stack.pop
		mctx.matched?.rollback(ctx)
	}

	override internal Void walk(PegCtx ctx, Match match) {
		mctx := (FirstOfRuleCtx) ctx.stack.pop
		mctx.matched.walk(mctx.matcha)
		action?.call(match)
	}

	override Str desc() {
		"(" + rules.join(" / ") + ")"
	}
	
	override Rule dup() { 
		FirstOfRule(rules.map { it.dup }) { it.name = this.name; it.action = this.action }
	}
}

internal class FirstOfRuleCtx {
	private Rule?	matched
	private Match?	matcha
}