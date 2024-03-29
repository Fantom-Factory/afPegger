
@Js
internal class RepetitionRule : Rule {
	private Int?		min
	private Int?		max
	private Rule		rule
	
	new make(Int? min, Int? max, Rule rule) {
		this.min	= min
		this.max	= max
		this.rule	= rule
	}
	
	override Bool doProcess(RuleCtx ctx) {
		count	:= 0
		pass	:= true
		while (pass && (max == null || count != max) && !ctx.eos) {
			ctx.log("Attempting x${count+1}")
			pass = ctx.process(rule)
			if (pass) count ++
		}

		minOkay := (min == null) || (count >= min)
		maxOkay := (max == null) || (count <= max)
		passed	:= minOkay && maxOkay
		
		if (count > 0)
			ctx.log(((rule.name ?: rule.label)?: "Rule") + " was successfully processed $count times")
		
		return passed
	}

	override Str _expression() {
		innerDesc := rule._dis

		if (min == 0 && max == 1)
			return "${innerDesc}?"
		if (min == 0 && max == null)
			return "${innerDesc}*"
		if (min == 1 && max == null)
			return "${innerDesc}+"
		min := min ?: Str.defVal
		max := max ?: Str.defVal
		return min == max ? "${innerDesc}{$min}" : "${innerDesc}{${min},${max}}"
	}
}
