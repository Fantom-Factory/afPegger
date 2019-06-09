
** (Advanced) 
** A helper class that lets you reference Rules before they're defined.
@Js
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

@Js
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
			action		= ruleForReal.action
			debug		= ruleForReal.debug
			useInResult	= ruleForReal.useInResult
		}
		return ruleForReal
	}
}

** A simple implementation of `NotFoundErr`.
** This class can not extend 'ArgErr' due to [Cannot extend sys Errs in Javascript]`http://fantom.org/forum/topic/2468`.
@Js internal const class ArgNotFoundErr : Err {
	const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super.make(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	** Pre-pends the list of available values to the stack trace.
	override Str toStr() {
		buf := StrBuf()
		buf.add("${typeof.qname}: ${msg}\n")
		buf.add("\nAvailable values:\n")
		availableValues.each { buf.add("  $it\n")}
		buf.add("\nStack Trace:")
		return buf.toStr
	}
}
