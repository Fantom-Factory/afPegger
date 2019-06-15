
@Js
internal class SequenceRule : Rule {
	private Rule[]		rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override Bool doProcess(ParseCtx ctx) {
		rules.all |Rule rule, i->Bool| {
			ctx.log("Attempting sequence ${i + 1} of ${rules.size}")
			pass := ctx.process(rule)
			if (!pass && rules.size > 1)
				ctx.log("Did not match ${rule}.")
			return pass
		}
	}

	override This add(Rule rule) {
		rules.add(rule)
		return this
	}

	override Str expression() {
		rules.join(" ") { it._dis(true) }
	}
}