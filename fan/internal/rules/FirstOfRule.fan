
@Js
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Bool doProcess(RuleCtx ctx) {
		// todo - autofail - we can NEVER rollback further than the FIRST "firstOf", or the last choice in any subsequent "firstOf" - each point is a FAIL point with syntax detail
		// not convinced this would give us any useful contextual feedback on a fail, much better if PEGs explicitly \err(FAIL)  
		rules.any |Rule rule, i->Bool| {
			// log the rule name (if exists), just in case its debug is turned off
			ctx.log("Attempting choice ${i + 1} of ${rules.size}" + (rule.name != null ? " (${rule.name})" : ""))
			return ctx.process(rule)
		}		
	}

	override This add(Rule rule) {
		rules.add(rule)
		return this
	}

	override Str _expression() {
		rules.join(" / ") { it._dis }
	}
}
