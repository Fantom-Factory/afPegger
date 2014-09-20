
internal class RepetitionRule : Rule {
	private Int?		min
	private Int?		max
	private Rule		rule
	
	new make(Int? min, Int? max, Rule rule) {
		this.min	= min
		this.max	= max
		this.rule	= rule
	}
	
	override Result walk(PegCtx ctx) {
		echo(name ?: desc)
		result	:= Result(name)
		
		results := Result[,]
		rulePass := true
		maxLimit := false
		while (rulePass && !maxLimit) {
			res := rule.walk(ctx)
			results.add(res)			
			rulePass = res.passed
			if (max != null && max == results.size)
				maxLimit = true
		}
		
		minOkay := (min == null) || (results.size >= min)
		maxOkay := (max == null) || (results.size <= max)
		pass	:= minOkay && maxOkay
		
		if (!pass) results.eachr { it.rollback() }

		if (pass) {
			result.results	= results 
			result.success	= |->| { result.results.each  { it.success()  }; this.action?.call(result) }
			result.rollback = |->| { result.results.eachr { it.rollback() } }
		}

		return result
	}

	override Str desc() {
		if (min == 0 && max == 1)
			return "${rule}?"
		if (min == 0 && max == null)
			return "${rule}*"
		if (min == 1 && max == null)
			return "${rule}+"
		min := min ?: Str.defVal
		max := max ?: Str.defVal
		return "${rule.name ?: rule.desc}{${min},${max}}"
	}
}
