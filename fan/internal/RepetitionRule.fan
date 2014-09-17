
internal class RepetitionRule : Rule {
	private Int?		min
	private Int?		max
	private Rule		rule
	private Rule[]?		rules
	private Match[]?	matches
	
	new make(Int? min, Int? max, Rule rule) {
		this.min	= min
		this.max	= max
		this.rule	= rule
	}
	
	override internal Match? match(PegCtx ctx) {
		rules   = Rule[,]
		matches = Match[,]
		matched := true
		while (matched) {
			r := rule.dup
			match := r.match(ctx)
			if (match != null) {
				matches.add(match)
				rules.add(r)
			}
			matched = (match != null)
		}
		
		minOkay := (min == null) || (matches.size >= min)
		maxOkay := (max == null) || (matches.size <= max)
		if (minOkay && maxOkay) {
			return Match(name, matches)
		} else {
			rollback(ctx)
			ctx.fail(this)
			return null
		}
	}
	
	override internal Void rollback(PegCtx ctx) {
		rules.each { it.rollback(ctx) }
	}
	
	override internal Void walk(Match match) {
		matches.each |m, i| { rules[i].walk(m) }
		action?.call(match)
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
		return "${rule}{${min},${max}}"
	}

	override This dup() { 
		RepetitionRule(min, max, rule.dup) { it.name = this.name; it.action = this.action }
	} 
}
