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
	
	override Result walk(PegInStream in) {
		rule.walk(in)
	}
	
	override Str desc() {
		rule.desc
	}
	
	override Str toStr() {
		rule.toStr
	}
	
	private Rule rule() {
		if (ruleForReal == null)
			ruleForReal = rules.getForReal(name)
		return ruleForReal
	}
}