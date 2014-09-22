
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result walk(PegCtx ctx) {
		result	:= Result(name)
		
		results := Result[,]
		pass := rules.all |Rule rule->Bool| {
			res := rule.walk(ctx)
			results.add(res)
			return res.matched
		}
		
		if (!pass) {
			result.failed(name, "${rules[results.size-1]} failed")
			results.eachr { it.rollback() }
		}
		
		if (pass) {
			result.passed(name, desc)
			result.results	= results 
			result.successFunc	= |->| { result.results.each  { it.success  }; this.action?.call(result) }
			result.rollbackFunc = |->| { result.results.eachr { it.rollback } }
		}		
		
		return result
	}

	override Str desc() {
		"(" + rules.join(" ") { it.name ?: it.desc } + ")"
	}
}