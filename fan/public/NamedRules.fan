using afBeanUtils

class NamedRules {
	private Str:Rule rules := Str:Rule[:] { caseInsensitive = true } 
	
	@Operator
	Rule get(Str name) {
		ProxyRule(this, name)
	}
	
	@Operator
	Rule set(Str name, Rule rule) {
		rules[name] = rule
		return rule
	}
	
	internal Rule getForReal(Str name) {
		rules[name] ?: throw ArgNotFoundErr("Could not find rule '$name'", rules.keys)
	}
}

internal class ProxyRule : Rule {
	private NamedRules 	rules
	private Rule?		ruleForReal

	new make(NamedRules rules, Str name) {
		this.name		= name
		this.rules		= rules
	}
	
	override |Result|?	action {
		get { rule.action }
		set { rule.action = it }
	}
	
	override Void doProcess(PegCtx ctx) {
		rule.doProcess(ctx)
	}
	
	override Str expression() {
		rule.expression
	}
	
	override Str toStr() {
		rule.toStr
	}
	
	private Rule rule() {
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