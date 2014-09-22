
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result walk(PegInStream in) {
		result	:= Result(name) 

		res 	:= (Result?) null
		winner	:= rules.find |Rule rule->Bool| {
			res = rule.walk(in)
			if (!res.matched)
				res.rollback()
			return res.matched
		}
		
		if (winner == null) {
			result.failed(name, desc)
		}
		
		if (winner != null) {
			result.passed(name, desc)
			result.results	= [res] 
			result.successFunc	= |->| { result.results.each { it.success  }; this.action?.call(result) }
			result.rollbackFunc = |->| { result.results.each { it.rollback } }
		}

		return result
	}

	override Str desc() {
		"(" + rules.join(" / ") { it.name ?: it.desc } + ")"
	}
}
