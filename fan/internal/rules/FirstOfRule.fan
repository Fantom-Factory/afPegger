
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result walk(PegCtx ctx) {
		result	:= Result(name) 

		res := (Result?) null
		
		winner	:= rules.find |Rule rule->Result?| {
			res = rule.walk(ctx)
			if (!res.passed)
				res.rollback()
			return res.passed
		}
		
		if (winner != null) {
			result.results	= [res] 
			result.success	= |->| { result.results.all { it.success  }; this.action(result) }
			result.rollback = |->| { result.results.all { it.rollback } }
		}

		return result
	}

	override Str desc() {
		"(" + rules.join(" / ") + ")"
	}
}
