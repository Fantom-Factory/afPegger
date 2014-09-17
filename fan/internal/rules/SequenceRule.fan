
internal class SequenceRule : Rule {
	private Rule[]		rules
//	private Match[]?	matches
	
	new make(Rule[] rules) {
		this.rules	= rules
	}

	override internal Match? match(PegCtx ctx) {
		failureCap := ctx.fails.size

		rules.each { 
			
		}
		
		
		matches = Match[,]
		matched := rules.all |rule->Bool| {
			match := rule.match(ctx)
			if (match != null)
				matches.add(match)
			return (match != null)
		}

		if (matched) {
			ctx.fails.size = failureCap
			return Match(name, matches)
		}

		rules[0..<matches.size].each { it.rollback(ctx) }
		ctx.fail(this)
		return null
	}
	
	override internal Void rollback(PegCtx ctx) {
		rules.each { it.rollback(ctx) }
	}

	override internal Void walk(Match match) {
		matches.each |m, i| { rules[i].walk(m) }
		action?.call(match)
	}

	override Str desc() {
		"(" + rules.join(" ") + ")"
	}

	override Rule dup() { 
		SequenceRule(rules.map { it.dup }) { it.name = this.name; it.action = this.action }
	} 
}