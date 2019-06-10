
@Js
internal class PegGrammar : Rules {

	static Grammar pegGrammar() {
		rules					:= Grammar()
		grammar					:= rules["grammar"]
		line					:= rules["line"]
		emptyLine				:= rules["emptyLine"]
		commentLine				:= rules["commentLine"]
		comment					:= rules["comment"]
		ruleDef					:= rules["ruleDef"]
		ruleName				:= rules["ruleName"]
		rule					:= rules["rule"]
		_sequence				:= rules["sequence"]
		_firstOf				:= rules["firstOf"]
		expression				:= rules["expression"]
		type					:= rules["type"]
		predicate				:= rules["predicate"]
		multiplicity			:= rules["multiplicity"]
		literal					:= rules["literal"]
		chars					:= rules["chars"]
		macro					:= rules["macro"]
		dot						:= rules["dot"]
		sp						:= rules["sp"]
		eos						:= eos { it.debug = false; it.useInResult = false }
		eol						:= eol { it.debug = false; it.useInResult = false }
		fail					:= err ("FAIL")

//		eos						= eos { it.useInResult = false }
//		eol						= eol { it.useInResult = false }

		rules["grammar"]		= oneOrMore(sequence { onlyIfNot(eos), line } )
		rules["line"]			= firstOf  { emptyLine, commentLine, ruleDef, fail, }
		rules["emptyLine"]		= sequence { zeroOrMore(sp), eol, }
		rules["commentLine"]	= sequence { zeroOrMore(sp), firstOf { char('#'), str("//"), }, zeroOrMore(sp), comment, eol, }
		rules["comment"]		= zeroOrMore(newLineChar(true))

		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(sp), firstOf { char('='), str("<-")}, zeroOrMore(sp), rule, zeroOrMore(sp), eol, }
		rules["ruleName"]		= sequence { charIn('a'..'z'), zeroOrMore(alphaNumChar), }

		rules["rule"]			= firstOf  { _firstOf, _sequence, fail, }
		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { oneOrMore(sp), expression, }), }
		rules["firstOf"]		= sequence { expression, zeroOrMore(sp), char('/'), zeroOrMore(sp), expression, zeroOrMore(sequence { zeroOrMore(sp), char('/'), zeroOrMore(sp), expression, }), }

		rules["expression"]		= sequence { optional(predicate), type, optional(multiplicity), }
		rules["type"]			= firstOf  { sequence { char('('), zeroOrMore(sp), rule, zeroOrMore(sp), char(')'), }, ruleName, literal, chars, macro, dot, fail, }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }
		rules["literal"]		= sequence { char('"'), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot('"'), }), char('"'), optional(char('i')), }
		rules["chars"]			= sequence { char('['), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot(']'), }), char(']'), optional(char('i')), }
		rules["macro"]			= sequence { char('\\'), oneOrMore(alphaChar), optional(sequence { char('('), zeroOrMore(charNotOf(")\n".chars)), char(')'), }), }
		rules["dot"]			= char('.')
		rules["sp"]				= spaceChar	{ it.debug = false; it.useInResult = false }
		
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
		lines := match.matches
		lines.each |line| {
			if (line.match.name == "ruleDef") {
				def  := line.match
				name := def["ruleName"].matched
				rule := toRule(def["rule"], newGrammar)
				rule.name = name
				newGrammar[name] = rule
			}
		}
		return newGrammar.validate
	}

	private Rule toRule(Match? match, Grammar? newGrammar) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		if (match.name != "rule")
			throw UnsupportedErr("Unknown rule: ${match.name}")

		return fromRule(match.match, newGrammar)
	}

	private Rule fromRule(Match match, Grammar? newGrammar) {
		rule := null as Rule
		switch (match.name) {
			case "sequence":
				if (match.matches.size == 1)
					rule = fromExpression(match.match, newGrammar)
				else {
					rules := match.matches.map { fromExpression(it, newGrammar) }
					rule = Rules.sequence(rules)
				}

			case "firstOf":
				rules := match.matches.map { fromExpression(it, newGrammar) }
				rule = Rules.firstOf(rules)
			
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
		exName	:= exType.match.name
		exRule	:= null as Rule

		switch (exName) {
			case "rule"		: exRule = fromRule(exType.match.match, newGrammar)
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
		
		return exRule
	}
	
	private Rule fromRuleName(Str ruleName, Grammar? newGrammar) {
		if (newGrammar == null)
			throw ParseErr("Patterns may not contain custom Grammar")
		return newGrammar[ruleName]
	}
	
	private Rule fromMacro(Str macro) {
		switch (macro[1..-1]) {
			case "n"		: return Rules.newLineChar
			case "space"	: return Rules.spaceChar
			case "white"	: 
			case "s"		: return Rules.whitespaceChar
			case "S"		: return Rules.whitespaceChar(true)
			case "digit"	: 
			case "d"		: return Rules.numChar
			case "D"		: return Rules.numChar(true)
			case "letter"	: 
			case "a"		: return Rules.alphaChar
			case "A"		: return Rules.alphaChar(true)
			case "w"		: return Rules.wordChar
			case "W"		: return Rules.wordChar(true)
			case "upper"	: return Rules.charIn('A'..'Z')
			case "lower"	: return Rules.charIn('a'..'z')
			case "ident"	: return Rules.sequence { Rules.charRule("[a-zA-Z_]"), Rules.zeroOrMore(Rules.wordChar), }
			case "eol"		: return Rules.eol
			case "eos"		: return Rules.eos
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
