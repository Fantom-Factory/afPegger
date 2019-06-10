
** (Advanced) 
** Use to programmatically define PEG rules.
** 
** Rules may be used before they, themselves are defined:
** 
**   syntax: fantom
**   grammar := Grammar()
**   grammar["a"] := Rules.sequence { grammar["b"], grammar["c"], }
**   grammar["b"] := Rules.zeroOrMore(Rules.spaceChar)
**   grammar["c"] := Rules.oneOrMore(Rules.alphaNumChar)
** 
** Sometimes it's easier to hold rules in local variables:
** 
**   syntax: fantom
**   grammar := Grammar()
**   
**   a            := grammar["a"]
**   b            := grammar["b"]
**   c            := grammar["c"]
** 
**   grammar["a"] := Rules.sequence { b, c, }
**   grammar["b"] := Rules.zeroOrMore(Rules.spaceChar)
**   grammar["c"] := Rules.oneOrMore(Rules.alphaNumChar)
** 
** All named rules must be defined before the grammar is used.
** 
** It is not mandatory to use the 'Grammar' class to create rules and grammars, but it is usually easier.
@Js
class Grammar {
	private Str:Rule 		_rules		:= Str:Rule[:] { it.ordered = true } 
	private Str:ProxyRule	_proxies	:= Str:ProxyRule[:] 
	
	** Parses grammar definitions, and returns the root rule (if given) or the first rule parsed.
	** For example:
	** 
	**   syntax: fantom 
	**   Grammar.fromDefs("a <- [abc] / [xyz] / b
	**                     b <- \space+ [^abc]")
	** 
	** See `Peg.parseGrammar`
	static Grammar parseGrammar(Str grammar) {
		PegGrammar().parseGrammar(grammar)
	}
	
	** Returns a proxy to the named rule.
	@Operator
	Rule get(Str name) {
		if (!_proxies.containsKey(name))
			_proxies[name] = ProxyRule(this, name)
		return _proxies[name]
	}
	
	** Sets the real implementation / definition of the named rule.
	@Operator
	Rule set(Str name, Rule rule) {
		_rules[name] = rule
		return rule
	}
	
	** Returns all the named rules.
	Rule[] rules() {
		validate._rules.vals
	}
	
	** Pretty prints the grammar definition.
	Str definition() {
		max := (Int) _rules.keys.reduce(0) |Int max, name| { max.max(name.size) }
		buf := StrBuf()
		_rules.each |rule| {
			buf.add(rule.name.justl(max)).add(" <- ").add(rule.expression).addChar('\n')
		}
		return buf.toStr		
	}
	
	internal This validate() {
		_proxies.vals.each { it.rule }
		// no need to warn of un-used rules - it may be irritating
		return this
	}
	
	internal Rule getForReal(Str name) {
		_rules[name] ?: throw ArgNotFoundErr("Rule not defined in grammar: $name", _rules.keys)
	}
	
	override Str toStr() { definition }
}

@Js
internal class ProxyRule : Rule {
	private Grammar 	rules
	private Rule?		ruleForReal

	new make(Grammar rules, Str name) {
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
@Js
internal const class ArgNotFoundErr : Err {
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
