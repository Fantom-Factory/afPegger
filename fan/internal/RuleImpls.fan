
// ---- Terminal / String Character Rules ---------------------------------------------------------

internal class CharRule : Rule {
	private  |Int->Bool|	func
	private  Str?			matched
	private  Str			str
	
	new make(Str str, |Int peek->Bool| func) {
		this.str  = str
		this.func = func
	}

	override internal Match? match(PegCtx ctx) {
		matched := ctx.readChar(this, func)
		return matched == null ? null : Match(name, matched.toChar)
	}
	
	override internal Void rollback(PegCtx ctx) {
		ctx.unread(1)
	}
	
	override Str desc() {
		str
	}
	
	override This dup() { 
		CharRule(str, func) { it.name = this.name; it.action = this.action }
	} 
}

internal class StrRule : Rule {
	private Str			str
	private Str?		matched
	
	new make(Str str) {
		this.str = str
	}
	
	override internal Match? match(PegCtx ctx) {
		matched := ctx.read(this, str.size) |peek->Bool| { peek == str }
		return matched == null ? null : Match(name, matched)
	}
	
	override internal Void rollback(PegCtx ctx) {
		ctx.unread(str.size)
	}
	
	override Str desc() {
		"\"${str}\""
	}

	override This dup() { 
		StrRule(str) { it.name = this.name; it.action = this.action }
	} 
}



// ---- Rule Rules --------------------------------------------------------------------------------

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

internal class SequenceRule : Rule {
	private Rule[]		rules
	private Match[]?	matches
	
	new make(Rule[] rules) {
		this.rules	= rules
	}

	override internal Match? match(PegCtx ctx) {
		failureCap := ctx.fails.size

		matches = Match[,]
		matched := rules.all |rule->Bool| {
			match := rule.match(ctx)
			if (match != null)
				matches.add(match)
			return (match != null)
		}

		if (matched) {
			ctx.fails.size = failureCap
			return Match(name, matches)
		}

		rules[0..<matches.size].each { it.rollback(ctx) }
		ctx.fail(this)
		return null
	}
	
	override internal Void rollback(PegCtx ctx) {
		rules.each { it.rollback(ctx) }
	}

	override internal Void walk(Match match) {
		matches.each |m, i| { rules[i].walk(m) }
		action?.call(match)
	}

	override Str desc() {
		"(" + rules.join(" ") + ")"
	}

	override This dup() { 
		SequenceRule(rules.map { it.dup }) { it.name = this.name; it.action = this.action }
	} 
}

internal class FirstOfRule : Rule {
	private Rule[]	rules
	private Rule?	matched
	private Match?	matcha
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override internal Match? match(PegCtx ctx) {
		failureCap := ctx.fails.size

		matcha = null
		matched = rules.find |rule->Bool| {
			matcha = rule.match(ctx)
			return (matcha != null)
		}

		if (matcha != null)
			ctx.fails.size = failureCap			

		return matcha
	}
	
	override internal Void rollback(PegCtx ctx) {
		matched?.rollback(ctx)
	}

	override internal Void walk(Match match) {
		matched.walk(matcha)
		action?.call(match)
	}

	override Str desc() {
		"(" + rules.join(" / ") + ")"
	}
	
	override This dup() { 
		FirstOfRule(rules.map { it.dup }) { it.name = this.name; it.action = this.action }
	} 
}
