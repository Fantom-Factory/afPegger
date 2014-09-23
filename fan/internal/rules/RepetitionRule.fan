
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
		count	:= 0
		pass	:= true
		while (pass && (max == null || count != max)) {
			pass = ctx.process(rule)
			if (pass) count ++
		}

		minOkay := (min == null) || (count >= min)
		maxOkay := (max == null) || (count <= max)
		passed	:= minOkay && maxOkay
		
		ctx.pass(passed)
	}

	override Str expression() {
		innerDesc := wrapRuleName(rule)

		if (min == 0 && max == 1)
			return "${innerDesc}?"
		if (min == 0 && max == null)
			return "${innerDesc}*"
		if (min == 1 && max == null)
			return "${innerDesc}+"
		min := min ?: Str.defVal
		max := max ?: Str.defVal
		return "${innerDesc}{${min},${max}}"
	}
	
	// TODO: pull this out into a helper method AND use it!
	static Str wrapRuleName(Rule rule) {
		desc := rule.name ?: rule.expression
		if (Regex<|[^\[]\s+[^\]]|>.matcher(desc).find) {
			if (desc.startsWith("(") && desc.endsWith(")")) {
				if (desc.index("(", 1) > desc.index(")", 1))
					desc = "(${desc})" 			
			} else
				desc = "(${desc})" 			
		}
		return desc
	}
}
