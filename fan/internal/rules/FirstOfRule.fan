
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result walk(PegCtx ctx) {
		echo(name ?: desc)
		result	:= Result(name) 

		res 	:= (Result?) null
		winner	:= rules.find |Rule rule->Bool| {
			res = rule.walk(ctx)
			if (!res.passed)
				res.rollback()
			return res.passed
		}
		
		if (winner != null) {
			result.results	= [res] 
			result.success	= |->| { result.results.each { it.success()  }; this.action?.call(result) }
			result.rollback = |->| { result.results.each { it.rollback() } }
		}

		return result
	}

	override Str desc() {
		"(" + rules.join(" / ") { it.name ?: it.desc } + ")"
	}
}
