
internal class RepetitionRule : Rule {
	private Int?		min
	private Int?		max
	private Rule		rule
	
	new make(Int? min, Int? max, Rule rule) {
		this.min	= min
		this.max	= max
		this.rule	= rule
	}
	
	override Result walk(PegInStream in) {
		result	:= Result(name)
		
		results := Result[,]
		rulePass := true
		maxLimit := false
		while (rulePass && !maxLimit) {
			res := rule.walk(in)
			if (res.matched) {
				results.add(res)
			} else {
				rulePass = false
				res.rollback()
			}
			if (max != null && max == results.size)
				maxLimit = true
		}
		
		minOkay := (min == null) || (results.size >= min)
		maxOkay := (max == null) || (results.size <= max)
		pass	:= minOkay && maxOkay
		
		// rollback the others that passed
		if (!pass) {
			result.failed(name, "${results.size} != $desc")
			results.eachr { it.rollback }
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
