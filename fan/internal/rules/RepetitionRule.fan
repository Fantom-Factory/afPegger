
internal class RepetitionRule : Rule {
	private Int?		min
	private Int?		max
	private Rule		rule
	
	new make(Int? min, Int? max, Rule rule) {
		this.min	= min
		this.max	= max
		this.rule	= rule
	}
	
	override Void doProcess(PegCtx ctx) {
		
		count := 0
		rulePass := true
		maxLimit := false
		while (rulePass && !maxLimit) {
			rulePass = ctx.process(rule)
			if (rulePass)
				count ++
			if (max != null && count == max)
				maxLimit = true
		}

		minOkay := (min == null) || (count >= min)
		maxOkay := (max == null) || (count <= max)
		passed	:= minOkay && maxOkay
		
		ctx.pass(passed)
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
