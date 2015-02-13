using afBeanUtils

** A helper class that lets you reference Rules before they're defined.
class NamedRules {
	private Str:Rule rules := Str:Rule[:] { caseInsensitive = true } 
	
	** Returns a proxy to the named rule.
	@Operator
	Rule get(Str name) {
		ProxyRule(this, name)
	}
	
	** Sets the real implementation of the named rule.
	@Operator
	Rule set(Str name, Rule rule) {
		rules[name] = rule
		return rule
	}
	
	internal Rule getForReal(Str name) {
		rules[name] ?: throw ArgNotFoundErr("Could not find rule '$name'", rules.keys)
	}
	
	override Str toStr() {
		rules.reduce("") |Str str, rule->Str| { str += rule.definition + "\n" }
	}
}

internal class ProxyRule : Rule {
	private NamedRules 	rules
	private Rule?		ruleForReal

	new make(NamedRules rules, Str name) {
		this.name		= name
		this.rules		= rules
	}
	
	override |Str|?	action {
		get { rule.action }
		set { rule.action = it }
	}
	
	override Bool doProcess(PegCtx ctx) {
		rule.doProcess(ctx)
	}
	
	override Str expression() {
		rule.expression
	}
	
	override Str toStr() {
		rule.toStr
	}
	
	internal Rule rule() {
		if (ruleForReal == null) {
			ruleForReal = rules.getForReal(name)
			if (ruleForReal.name == null)
				ruleForReal.name = name
			else
				name = ruleForReal.name
			action = ruleForReal.action
		}
		return ruleForReal
	}
}