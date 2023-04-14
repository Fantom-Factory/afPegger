
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
	private Str:Rule 		_rules		:= Str:Rule[:]      { it.ordered = true } 
	private Str:ProxyRule	_proxies	:= Str:ProxyRule[:] { it.ordered = true }
	
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
	
	** Returns the first declared rule.
	@NoDoc	// only really used / needed for automation / testing 
	Rule firstRule() {
		_rules[_rules.keys.first]
	}
	
	** Returns the named rule, or creates a proxy if it doesn't exist.
	@Operator
	Rule get(Str name) {
		if (_rules.containsKey(name))
			return _rules[name]
		if (_proxies.containsKey(name))
			return _proxies[name]
		_proxies[name] = ProxyGrammarRule(this, name) { it.name = name }
		return _proxies[name]
	}
	
	** Sets the real implementation / definition of the named rule.
	@Operator
	Rule set(Str name, Rule rule) {
		if (rule.name != null && rule isnot RuleRef)
			throw Err("Rule '${rule.name}' is already a definition")
		if (rule.label != null && rule isnot RuleRef)
			throw Err("Definitions can NOT have labels: ${name}:${rule.label}")
		rule.name = name
		_rules[name] = rule
		return rule
	}
	
	** Returns all the named rules.
	Rule[] rules() {
		validate._rules.vals
	}
	
	** Pretty prints the grammar definition.
	Str definition() {
		validate
		max := (Int) _rules.vals.reduce(0) |Int max, rule| {
			nameSize := rule.name.size
			if (!rule.useInResult)	nameSize++
			if (!rule.debug)		nameSize++
			return max.max(nameSize)
		}
		buf := StrBuf()
		_rules.each |rule| {
			name := rule.name
			if (!rule.useInResult)	name = "-" + name
			if (!rule.debug)		name = name + "-"
			buf.add(name.justl(max)).add(" <- ").add(rule.expression).addChar('\n')
		}
		return buf.toStr
	}
	
	** Dumps the definition to std-out.
	@NoDoc
	This dump(OutStream out := Env.cur.out) {
		out.printLine(debugStr)
		return this
	}
	
	** Returns the definition.
	@NoDoc
	Str debugStr() {
		definition
	}
	
	** Validates that all named rules have been defined. 
	This validate() {
		_proxies.vals.each { it.rule(true) }
		// no need to warn of un-used rules - it may be irritating
		return this
	}
	
	internal Rule? getForReal(Str name, Bool checked) {
		_rules[name] ?: (checked ? throw ArgNotFoundErr("Rule not defined in grammar: $name", _rules.keys) : null)
	}
	
	@NoDoc
	override Str toStr() { debugStr }
}

@Js
internal abstract class ProxyRule : Rule {
	private Str?	_name
	private Str?	_label
	private Bool?	_debug
	private Bool?	_useInResult
	
	override Str? name {
		get { rule?.name ?: _name}
		set { if (rule == null) _name = it; else rule.name = it }
	}

	override Str? label {
		get { rule?.label ?: _label}
		set { throw Err("ProxyRules (${name}) should NOT have their label set: $it") }
	}
	
	override Bool debug {
		get { rule?.debug ?: _debug }
		set { if (rule == null) _debug = it; else rule.debug = it }
	}

	override Bool useInResult {
		get { rule?.useInResult ?: _useInResult }
		set { if (rule == null) _useInResult = it; else rule.useInResult = it }
	}

	override Bool doProcess(RuleCtx ctx) {
		rule(true).doProcess(ctx)
	}
	
	override Str _expression() {
		rule(true)._expression
	}
	
	override Str toStr() {
		rule(true).toStr
	}
	
	abstract Rule? rule(Bool checked := false)
	
	Void onRule(Rule rule) {
		if (_name		 != null)	rule.name		 = _name
		if (_label		 != null)	rule.label		 = _label
		if (_debug		 != null)	rule.debug		 = _debug
		if (_useInResult != null)	rule.useInResult = _useInResult
	}
	
	Bool hasIdentityCrisis(Rule realRule) {
		// labels should NOT be inherited
		if (realRule.label != null)
			return true
		// names are allowed to be the same
		if (realRule.name  != null && realRule.name != _name)
			return true

		// phew! we know who we are!
		return false
	}
}

@Js
internal class ProxyGrammarRule : ProxyRule {
	private Grammar 	rules
	private Rule?		realRule
	private const Str	realName
	
	new make(Grammar rules, Str? realName) {
		// let the actual name be whatever, just don't change who we point to!
		this.realName	= realName
		this.rules		= rules
	}
	
	override Rule? rule(Bool checked := false) {
		if (realRule == null) {
			realRule = rules.getForReal(realName, checked)
			if (realRule != null) {
				
				if (hasIdentityCrisis(realRule))
					realRule = SequenceRule([realRule])
				
				onRule(realRule)
			}
		}
		return realRule
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
