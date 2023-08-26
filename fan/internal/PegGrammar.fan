
@Js
internal class PegGrammar : Rules {

	static Grammar pegGrammar() {
		rules					:= Grammar()
		grammar					:= rules["grammar"]
		ruleDef					:= rules["ruleDef"]
		ruleName				:= rules["ruleName"]
		rule					:= rules["rule"]
		_sequence				:= rules["sequence"]
		_firstOf				:= rules["firstOf"]
		expression				:= rules["expression"]
		label					:= rules["label"]
		type					:= rules["type"]
		group					:= rules["group"]		.excludeFromResults
		predicate				:= rules["predicate"]
		multiplicity			:= rules["multiplicity"]
		literal					:= rules["literal"]
		singleQuote				:= rules["singleQuote"].excludeFromResults
		doubleQuote				:= rules["doubleQuote"].excludeFromResults
		chars					:= rules["chars"]
		macro					:= rules["macro"]
		unicode					:= rules["unicode"]
		dot						:= rules["dot"]
		commentLine				:= rules["commentLine"]	.excludeFromResults.debugOff
		comment					:= rules["comment"]		.excludeFromResults.debugOff
		cwsp					:= rules["cwsp"]		.excludeFromResults.debugOff
		cnl						:= rules["cnl"]			.excludeFromResults.debugOff
		sp						:= rules["sp"]			.excludeFromResults.debugOff
		nl						:= rules["nl"]			.excludeFromResults.debugOff
		eos						:= eos					.excludeFromResults.debugOff
		sos						:= sos					.excludeFromResults.debugOff
		fail					:= err ("FAIL")

		rules["grammar"]		= oneOrMore( sequence { onlyIfNot(eos), firstOf { commentLine, ruleDef, fail, }, })

		rules["ruleDef"]		= sequence { optional(char('-')).withLabel("exclude"), ruleName, optional(char('-')).withLabel("debugOff"), zeroOrMore(cwsp), firstOf { char('='), str("<-")}, zeroOrMore(cwsp), rule, optional(commentLine), }
		rules["ruleName"]		= sequence { alphaChar, zeroOrMore(firstOf { sequence { char('-'), charRule("[a-zA-Z0-9_]"), }, charRule("[a-zA-Z0-9_]"), }), }
		rules["rule"]			= firstOf  { _firstOf, fail, }
		rules["firstOf"]		= sequence { _sequence, zeroOrMore(sequence { zeroOrMore(cwsp), char('/'), zeroOrMore(cwsp), _sequence, }), }
		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { zeroOrMore(cwsp), expression, }), }

		rules["expression"]		= sequence { optional(predicate), optional(sequence { label, char(':') } ), type, optional(multiplicity), }
		rules["label"]			= sequence { alphaChar, zeroOrMore(charRule("[a-zA-Z0-9_\\-]")), }
		rules["type"]			= firstOf  { group, ruleName, literal, chars, macro, dot, }
		rules["group"]			= sequence { char('('), zeroOrMore(cwsp), rule, zeroOrMore(cwsp), char(')'), }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), sequence { char('{'), zeroOrMore(numChar).withLabel("min"), optional( sequence { char(',').withLabel("com").debugOff, zeroOrMore(numChar).withLabel("max"), } ), char('}') }, }

		rules["literal"]		= firstOf  { singleQuote, doubleQuote, }
		rules["singleQuote"]	= sequence { char('\''), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot('\''), }), char('\''), optional(char('i')), }	// if you escape something, then it MUST be followed by another char
		rules["doubleQuote"]	= sequence { char('"' ), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot('"' ), }), char('"' ), optional(char('i')), }
		rules["chars"]			= sequence { char('[' ), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot(']' ), }), char(']' ), optional(char('i')), }
		rules["macro"]			= sequence { char('\\'), oneOrMore(alphaChar), optional(sequence { char('('), zeroOrMore(charNotOf(")\n".chars)), char(')'), }), }
		rules["unicode"]		= sequence { char('\\'), char('u'), hexChar, hexChar, hexChar, hexChar, }
		rules["dot"]			= char('.')

		rules["commentLine"]	= sequence { zeroOrMore(sp), firstOf { nl, comment, }, }
		rules["comment"]		= sequence { firstOf { char('#'), str("//"), }, zeroOrMore(sequence { onlyIfNot(eos), charNot('\n'), }), nl, }
		rules["cwsp"]			= firstOf { sp, sequence { onlyIfNot(eos), cnl, firstOf { sp, onlyIf(firstOf { char('#'), str("//"), }), } },}
		rules["cnl"]			= firstOf { nl, comment, }
		rules["sp"]				= spaceChar
		rules["nl"]				= firstOf { eos, char('\n'), } 
		
		return rules.validate
	}
	
	Rule parseRule(Str pattern) {
		peg := Peg(pattern.trim, pegGrammar["rule"])
		return toRule(peg.match, null)
	}
	
	Grammar parseGrammar(Str grammar) {
		peg := Peg(grammar, pegGrammar["grammar"])
		return toGrammar(peg.match)
	}

	// ---- Helper methods ----
	
	private Grammar toGrammar(Match? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		assertName(match, "grammar")
		
		newGrammar := Grammar()
		match.matches.each |ruleDef| {
			assertName(ruleDef, "ruleDef")
				
			excl := ruleDef.contains("exclude")
			name := ruleDef["ruleName"].matched
			dOff := ruleDef.contains("debugOff")
			rule := toRule(ruleDef["rule"], newGrammar)
			if (excl) rule.excludeFromResults
			if (dOff) rule.debugOff
			newGrammar[name] = rule
		}
		return newGrammar.validate
	}

	private Rule toRule(Match? match, Grammar? newGrammar) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		assertName(match, "rule")

		return fromRule(match.firstMatch, newGrammar)
	}

	private Rule fromRule(Match match, Grammar? newGrammar) {
		rule := null as Rule
		switch (match.name) {
			case "sequence":
				rules := match.matches.map { fromExpression(it, newGrammar) }
				rule = rules.size == 1 ? rules.first : Rules.sequence(rules)

			case "firstOf":
				rules := match.matches.map { fromRule(it, newGrammar) }
				rule = rules.size == 1 ? rules.first : Rules.firstOf(rules)
			
			default:
				throw UnsupportedErr("Unknown rule: ${match.name}")
		}
		return rule
	}
	
	private Rule fromExpression(Match match, Grammar? newGrammar) {
		assertName(match, "expression")

		exType	:= match["type"] as Match
		multi	:= match["multiplicity"]
		pred	:= match["predicate"]?.matched
		exName	:= exType.firstMatch.name
		exRule	:= null as Rule

		switch (exName) {
			case "rule"		: exRule = fromRule(exType.firstMatch.firstMatch, newGrammar)
			case "ruleName"	: exRule = fromRuleName(match, exType.matched, newGrammar)
			case "literal"	: exRule = StrRule.fromStr(exType.matched)
			case "chars"	: exRule = CharRule.fromStr(exType.matched)
			case "macro"	: exRule = fromMacro(exType.matched)
			case "dot"		: exRule = Rules.anyChar
			default			: throw UnsupportedErr("Unknown expression: ${exName}")
		}
		
		if (multi != null)
			switch (multi.matched) {
				case "?"	: exRule = Rules.optional(exRule)
				case "+"	: exRule = Rules.oneOrMore(exRule)
				case "*"	: exRule = Rules.zeroOrMore(exRule)
				default		:
					min	:= multi["min"]?.matched?.trimToNull?.toInt
					com	:= multi["com"]?.matched
					max	:= multi["max"]?.matched?.trimToNull?.toInt
					exRule = com != null ? Rules.between(min, max, exRule) : Rules.nTimes(min, exRule)
			}

		if (pred != null)
			switch (pred) {
				case "&"	: exRule = Rules.onlyIf(exRule)
				case "!"	: exRule = Rules.onlyIfNot(exRule)
				default		: throw UnsupportedErr("Unknown predicate: ${pred}")
			}

		label	:= match["label"]?.matched
		if (label != null) {
			// actually, using RuleRefs, we can! And this ParseErr never gets thrown!
			if (exRule.label != null)
				throw ParseErr("Cannot overwrite rule label '${exRule.label}' with '${label}'" + (exRule.name != null ? " (on rule '${exRule.name}')" : ""))

			exRule.label = label
		}

		return exRule
	}
	
	private Rule fromRuleName(Match match, Str ruleName, Grammar? newGrammar) {
		if (newGrammar == null)
			throw ParseErr("Patterns may not contain custom Grammar")
		
		origRule := newGrammar[ruleName]
		// return a "pointer" to the actual rule
		rule	 := RuleRef(origRule) as Rule
		
		// let rule refs define labels
		label	 := match.getMatch("label")
		if (label != null) {
			// add the label manually to the inner RuleRef
			// the outer wrapping SequenceRule is NOT allowed a label - 'cos it may be a top level definition
			rule.label = label.matched
			match.matches.removeSame(label)
			rule = SequenceRule([rule])
		}

		return rule
	}

	private Rule fromMacro(Str macro) {
		switch (macro[1..-1]) {
			case "sos"		: return Rules.sos
			case "eos"		: return Rules.eos
			case "sol"		: return Rules.sol
			case "eol"		: return Rules.eol

			case "upper"	: return Rules.upper
			case "lower"	: return Rules.lower
			case "alpha"	: return Rules.alpha

			case "pass"		: return Rules.pass
			case "fail"		: return Rules.fail

			// todo I don't even like these either!
//			case "a"		: return Rules.alphaChar
//			case "d"		: return Rules.numChar
//			case "n"		: return Rules.newLineChar
//			case "s"		: return Rules.whitespaceChar
//			case "w"		: return Rules.wordChar
//			case "sp"		: return Rules.spaceChar

			// todo do I actually want all these macros?
//			case "A"		: return Rules.alphaChar(true)
//			case "D"		: return Rules.numChar(true)
//			case "S"		: return Rules.whitespaceChar(true)
//			case "W"		: return Rules.wordChar(true)
//			case "space"	: return Rules.spaceChar
//			case "white"	: return Rules.whitespaceChar
//			case "digit"	: return Rules.numChar
//			case "letter"	: return Rules.alphaChar
//			case "upper"	: return Rules.charIn('A'..'Z')
//			case "lower"	: return Rules.charIn('a'..'z')
//			case "ident"	: return Rules.sequence { Rules.charRule("[a-zA-Z_]"), Rules.zeroOrMore(Rules.wordChar), }
		}

		if (macro.startsWith("\\err(") && macro.endsWith(")"))
			return Rules.err(deEscape(macro[5..<-1]))
//		if (macro.startsWith("\\dump(") && macro.endsWith(")"))
//			return Rules.dump(deEscape(macro[6..<-1]))
//		if (macro.startsWith("\\noop(") && macro.endsWith(")")) {
//			text := deEscape(macro[6..<-1])
//			bool := Bool.fromStr(text, false) ?: throw UnsupportedErr("No-Op marco only accepts 'true' and 'false': ${text}")
//			return Rules.noop(bool)
//		}
		
		throw UnsupportedErr("Unknown macro: $macro")
	}
	
	private Str deEscape(Str str) {
		str.replace("\\\"", "\"").replace("\\t", "\t").replace("\\n", "\n").replace("\\r", "\r").replace("\\f", "\f").replace("\\\\", "\\")
	}
	
	private Void assertName(Match m, Str name) {
		if (m.name != name) 
			throw ParseErr("Match should be '${name}', not '${m.name}'")
	}
}

@Js
internal class RuleRef : Rule {
	private Rule realRule

	// todo future versions of Pegger should distinguish between top-level grammar rules,
	// and rules that are part of an expression 
	
	private Str? _name
	override Str? name {
		// this conditional delegation of "name" is complicated, but revolves around being a definition / top level rule or not
		get { _name ?: realRule.name }
		set { _name = it }
	}

	private Bool? _useInResult
	override Bool useInResult {
		// generally, if we go to the effort of giving something a label - we want it in the result tree!
		get { (label != null || _name != null) ? (_useInResult ?: true) : realRule.useInResult }
		set { 
			if (label != null || _name != null)
				_useInResult = it
			else
				realRule.useInResult = it 
		}
	}

//	override Bool debug {
//		get { realRule.debug }
//		set { throw UnsupportedErr("RuleRefs (${name}) should NOT have their 'debug' set") }
//	}

	private Bool? _debug
	override Bool debug {
		// generally, if we go to the effort of giving something a label - we want it debugged!
		get { (label != null || _name != null) ? (_debug ?: true) : realRule.debug }
		set { 
			if (label != null || _name != null)
				_debug = it
			else
				realRule.debug = it 
		}
	}
	
	new make(Rule realRule) {
		this.realRule	= realRule
	}
	
	override Bool doProcess(RuleCtx ctx)	{ realRule.doProcess(ctx) }
	override Str _expression()				{ realRule.name }
}
