
@Js
internal class FirstOfRule : Rule {
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Bool doProcess(PegCtx ctx) {
		// TODO we can NEVER rollback further than the FIRST "firstOf", or the last choice in any subsequent "firstOf" - each point is a FAIL point with syntax detail 
		rules.any |Rule rule->Bool| {
			ctx.process(rule)
		}		
	}

	override This add(Rule rule) {
		rules.add(rule)
		return this
	}

	override Str expression() {
		rules.join(" / ") { it.dis }
	}
}
