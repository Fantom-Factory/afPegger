
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Result walk(PegCtx ctx) {
		result	:= Result(name)
		
		results := Result[,]
		rules.all {
			
		}
		
		return result

		results := [,]
		
		pass := rules.all |Rule rule->Bool| {
			res := rule.walk(ctx)
			results.add(res)
			return res.match
		}

		
		if (pass) {
			return Result(name) {
				it.results	= results 
				it.success	= |->| { this.action(it); results.each { it.success() } }
				it.rollback	= |->| { results.each { it.rollback() } }
			} 
		} else {
			results.each { it.rollback() }
			return Result(name) {
				it.results	= results 
				it.success	= |->| { this.action(it); results.each { it.success() } }
				it.rollback	= |->| { results.each { it.rollback() } }
			} 
		}
		
		return (result == null) 
			? Result(name) {
				it.results = [result] 
				it.successFunc = |->| { this.action(it) }
			} 
			: Result(name, |->| { ctx.unread(1)})
	}

//	override internal Match? match(PegCtx ctx) {
//		failureCap := ctx.fails.size
//
//		rules.each { 
//			
//		}
//		
//		
//		matches = Match[,]
//		matched := rules.all |rule->Bool| {
//			match := rule.match(ctx)
//			if (match != null)
//				matches.add(match)
//			return (match != null)
//		}
//
//		if (matched) {
//			ctx.fails.size = failureCap
//			return Match(name, matches)
//		}
//
//		rules[0..<matches.size].each { it.rollback(ctx) }
//		ctx.fail(this)
//		return null
//	}
	
//	override internal Void rollback(PegCtx ctx) {
//		rules.each { it.rollback(ctx) }
//	}
//
//	override internal Void walk(Match match) {
//		matches.each |m, i| { rules[i].walk(m) }
//		action?.call(match)
//	}

	override Str desc() {
		"(" + rules.join(" ") + ")"
	}
}