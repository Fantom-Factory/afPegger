
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result match(PegCtx ctx) {
		result	:= Result(name)
		
		results := Result[,]
		pass := rules.all |Rule rule->Bool| {
			res := rule.match(ctx)
			results.add(res)
			return res.matched
		}
		
		if (!pass) {
			result.ruleFailed("${rules[results.size-1]} failed")
			results.eachr { it.rollback }
		}
		
		if (pass) {
			result.passed(desc)
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