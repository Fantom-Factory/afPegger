
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
		emptyLine				:= rules["emptyLine"]
		comment					:= rules["comment"]		.debugOff
		cwsp					:= rules["cwsp"]		.excludeFromResults.debugOff
		cnl						:= rules["cnl"]			.excludeFromResults.debugOff
		sp						:= rules["sp"]			.excludeFromResults.debugOff
		eos						:= eos					.excludeFromResults.debugOff
		eol						:= eol					.excludeFromResults.debugOff
		fail					:= err ("FAIL")

		rules["grammar"]		= oneOrMore( sequence { onlyIfNot(eos), firstOf { emptyLine, ruleDef, fail, }, })

		rules["ruleDef"]		= sequence { optional(char('-')).withLabel("exclude"), ruleName, optional(char('-')).withLabel("debugOff"), zeroOrMore(cwsp), firstOf { char('='), str("<-")}, zeroOrMore(cwsp), rule, zeroOrMore(cwsp), eol, }
//		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(cwsp), firstOf { char('='), str("<-")}, zeroOrMore(cwsp), rule, zeroOrMore(cwsp), optional(eol), }
//		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(cwsp), firstOf { char('='), str("<-")}, zeroOrMore(cwsp), rule, zeroOrMore(sp), firstOf { eol, oneOrMore(emptyLine), }, }
//		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(cwsp), firstOf { char('='), str("<-")}, zeroOrMore(cwsp), rule, firstOf { eos, oneOrMore(emptyLine), }, }
		rules["ruleName"]		= sequence { alphaChar, zeroOrMore(charRule("[a-zA-Z0-9_\\-]")), }
		rules["rule"]			= firstOf  { _firstOf, err("FAIL-2"), }
		rules["firstOf"]		= sequence { _sequence, zeroOrMore(sequence { zeroOrMore(cwsp), char('/'), zeroOrMore(cwsp), _sequence, }), }
		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { zeroOrMore(cwsp), expression, }), }

		rules["expression"]		= sequence { optional(predicate), optional(sequence { label, char(':') } ), type, optional(multiplicity), }
		rules["label"]			= sequence { alphaChar, zeroOrMore(charRule("[a-zA-Z0-9_\\-]")), }
		rules["type"]			= firstOf  { group, ruleName, literal, chars, macro, dot, }
		rules["group"]			= sequence { char('('), zeroOrMore(cwsp), rule, zeroOrMore(cwsp), char(')'), }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }

		rules["literal"]		= firstOf  { singleQuote, doubleQuote, }
		rules["singleQuote"]	= sequence { char('\''), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot('\''), }), char('\''), optional(char('i')), }	// if you escape something, then it MUST be followed by another char
		rules["doubleQuote"]	= sequence { char('"' ), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot('"' ), }), char('"' ), optional(char('i')), }
		rules["chars"]			= sequence { char('[' ), oneOrMore(firstOf { unicode, sequence { char('\\'), anyChar, }, charNot(']' ), }), char(']' ), optional(char('i')), }
		rules["macro"]			= sequence { char('\\'), oneOrMore(alphaChar), optional(sequence { char('('), zeroOrMore(charNotOf(")\n".chars)), char(')'), }), }
		rules["unicode"]		= sequence { char('\\'), char('u'), hexChar, hexChar, hexChar, hexChar, }
		rules["dot"]			= char('.')

		rules["emptyLine"]		= sequence { zeroOrMore(sp), firstOf { eol, comment, }, }
		rules["comment"]		= sequence { firstOf { char('#'), str("//"), }, zeroOrMore(sequence { onlyIfNot(eos), charNot('\n'), }), eol, }
		rules["cwsp"]			= firstOf { sp, sequence { onlyIfNot(eos), cnl, firstOf { sp, comment, eos, }, },}
//		rules["cwsp"]			= firstOf { sp, sequence { onlyIfNot(eos), cnl, firstOf { sp, onlyIf(char('#')), }, }, }
//		rules["cwsp"]			= firstOf { sp, sequence { onlyIfNot(eos), cnl, firstOf { sp, eos, }, },}
//		rules["cwsp"]			= firstOf { sp, sequence { onlyIfNot(eos), cnl, firstOf { sp, comment, eos, }, },}
		rules["cnl"]			= firstOf { eol, comment, }
		rules["sp"]				= spaceChar
		
		return rules.validate
	}
	
	Rule parseRule(Str pattern) {
		peg := Peg(pattern, pegGrammar["rule"])
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
		if (match.name != "grammar")
			throw UnsupportedErr("Unknown rule: ${match.name}")
		
		newGrammar := Grammar()
		match.matches.each |ruleDef| {
			if (ruleDef.name == "emptyLine") 
				return
			if (ruleDef.name != "ruleDef") 
				throw ParseErr("Not a ruleDef: ${ruleDef.name}")
				
			excl := ruleDef.contains("exclude")
			name := ruleDef["ruleName"].matched
			dOff := ruleDef.contains("debugOff")
			rule := toRule(ruleDef["rule"], newGrammar)
			rule.name = name
			if (excl) rule.excludeFromResults
			if (dOff) rule.debugOff
			newGrammar[name] = rule
		}
		return newGrammar.validate
	}

	private Rule toRule(Match? match, Grammar? newGrammar) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		if (match.name != "rule")
			throw UnsupportedErr("Unknown rule: ${match.name}")

		return fromRule(match.firstMatch, newGrammar)
	}

	private Rule fromRule(Match match, Grammar? newGrammar) {
		rule := null as Rule
		switch (match.name) {
			case "sequence":
				if (match.matches.size == 1)
					rule = fromExpression(match.firstMatch, newGrammar)
				else {
					rules := match.matches.findAll { it.name != "comment" }.map {
						fromExpression(it, newGrammar)
					}
					rule = Rules.sequence(rules)
				}

			case "firstOf":
				rules := match.matches.map { fromRule(it, newGrammar) }
				rule = rules.size == 1 ? rules.first : Rules.firstOf(rules)
			
			default:
				throw UnsupportedErr("Unknown rule: ${match.name}")
		}
		return rule
	}
	
	private Rule fromExpression(Match match, Grammar? newGrammar) {
		if (match.name != "expression")
			throw ArgErr("Match should be 'expression', not '${match.name}'")

		exType	:= match["type"] as Match
		multi	:= match["multiplicity"]?.matched
		pred	:= match["predicate"]?.matched
		label	:= match["label"]?.matched
		exName	:= exType.firstMatch.name
		exRule	:= null as Rule

		switch (exName) {
			case "rule"		: exRule = fromRule(exType.firstMatch.firstMatch, newGrammar)
			case "ruleName"	: exRule = fromRuleName(exType.matched, newGrammar)
			case "literal"	: exRule = StrRule.fromStr(exType.matched)
			case "chars"	: exRule = CharRule.fromStr(exType.matched)
			case "macro"	: exRule = fromMacro(exType.matched)
			case "dot"		: exRule = Rules.anyChar
			default			: throw UnsupportedErr("Unknown expression: ${exName}")
		}
		
		if (multi != null)
			switch (multi) {
				case "?"	: exRule = Rules.optional(exRule)
				case "+"	: exRule = Rules.oneOrMore(exRule)
				case "*"	: exRule = Rules.zeroOrMore(exRule)
				default		: throw UnsupportedErr("Unknown multiplicity: ${multi}")
			}
		
		if (pred != null)
			switch (pred) {
				case "&"	: exRule = Rules.onlyIf(exRule)
				case "!"	: exRule = Rules.onlyIfNot(exRule)
				default		: throw UnsupportedErr("Unknown predicate: ${pred}")
			}
		
		if (label != null) {
			exRule = ProxyLabelRule(exRule)
//			if (exRule.label != null)
//				throw ParseErr("Cannot overwrite rule label '${exRule.label}' with '${label}'" + (exRule.name != null ? " (on rule '${exRule.name}')" : ""))
			exRule.label = label
		}

		return exRule
	}
	
	private Rule fromRuleName(Str ruleName, Grammar? newGrammar) {
		if (newGrammar == null)
			throw ParseErr("Patterns may not contain custom Grammar")
		return newGrammar[ruleName]
	}
	
	private Rule fromMacro(Str macro) {
		switch (macro[1..-1]) {
			case "eol"		: return Rules.eol
			case "eos"		: return Rules.eos
			case "upper"	: return Rules.upper
			case "lower"	: return Rules.lower
			case "alpha"	: return Rules.alpha

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
		if (macro.startsWith("\\noop(") && macro.endsWith(")"))
			return Rules.noop(deEscape(macro[6..<-1]))
		
		throw UnsupportedErr("Unknown macro: $macro")
	}
	
	private Str deEscape(Str str) {
		str.replace("\\\"", "\"").replace("\\t", "\t").replace("\\n", "\n").replace("\\r", "\r").replace("\\f", "\f").replace("\\\\", "\\")
	}
}

@Js
internal class ProxyLabelRule : ProxyRule {
	private Rule realRule
	private Str? _label2
	override Str? label {
		get { _label2 }
		set { _label2 = it }
	}
	
	new make(Rule realRule) {
		this.realRule	= realRule
	}
	
	override Rule? rule(Bool checked := false) {
		realRule
	}
}
