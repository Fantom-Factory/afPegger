
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result match(PegCtx ctx) {
		result	:= Result(name) 

		res 	:= (Result?) null
		winner	:= rules.find |Rule rule->Bool| {
			res = rule.match(ctx)
			if (!res.matched)
				res.rollback
			return res.matched
		}
		
		if (winner == null) {
			result.ruleFailed(desc)
		}
		
		if (winner != null) {
			result.passed(desc)
			result.results	= [res] 
			result.successFunc	= |->| { result.results.each  { it.success  }; this.action?.call(result) }
			result.rollbackFunc = |->| { result.results.eachr { it.rollback } }
		}

		return result
	}

	override Str desc() {
		"(" + rules.join(" / ") { it.name ?: it.desc } + ")"
	}
}
