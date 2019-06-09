
@Js
internal class PegGrammar : Rules {
	
	private NamedRules rules() {
		rules			:= NamedRules()
		line			:= rules["line"]
		emptyLine		:= rules["emptyLine"]
		commentLine		:= rules["commentLine"]
		ruleDef			:= rules["ruleDef"]
		ruleName		:= rules["ruleName"]
		rule			:= rules["rule"]
		_sequence		:= rules["sequence"]
		_firstOf		:= rules["firstOf"]
		expression		:= rules["expression"]
		predicate		:= rules["predicate"]
		multiplicity	:= rules["multiplicity"]
		literal			:= rules["literal"]
		chars			:= rules["chars"]
		macro			:= rules["macro"]
		dot				:= rules["dot"]
		WSP				:= rules["WSP"]
		NL				:= rules["NL"]
		EOS				:= rules["EOS"]
		FAIL			:= rules["FAIL"]
		
//		ruleDef			= ruleName WSP* ":" WSP* rule (NL / EOS)		// what of multiline?
//		ruleName		= [a-z]i [a-z0-9]i*
//
//		rule			= firstOf / sequence / FAIL
//		sequence		= expression (WSP+ expression)*
//		firstOf			= expression WSP+ "/" WSP+ expression (WSP+ "/" WSP+ expression)*
//		
//		expression		= predicate? ("(" rule ")" / ruleName / literal / chars / dot) multiplicity?
//		predicate		= "!" / "&"
//		multiplicity	= "*" / "+" / "?"
//		literal			= ("\"" (("\" [\\"fnrt]) / [^"])+ "\"") / ("'" (("\" [\\'fnrt]) / [^'])+ "'")
//		chars			= "[" "^"? (("\" [\\"fnrt]) / ([a-zA-Z0-9] "-" [a-zA-Z0-9]) / [a-zA-Z0-9])+ "]" "i"?
//		dot				= "."
		
		rules["line"]			= firstOf  { emptyLine, commentLine, ruleDef, FAIL, }
		rules["emptyLine"]		= sequence { zeroOrMore(WSP), firstOf { NL, EOS, }, }
		rules["commentLine"]	= sequence { zeroOrMore(WSP), str("//"), zeroOrMore(anyChar), firstOf { NL, EOS, }, }
		
//		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(WSP), char('='), zeroOrMore(WSP), oneOrMore(anyChar), firstOf { NL, EOS, }, }
		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(WSP), char('='), zeroOrMore(WSP), rule, firstOf { NL, EOS, }, }
		
		rules["ruleName"]		= sequence { charIn('a'..'z'), zeroOrMore(alphaNumChar), }

		rules["rule"]			= firstOf  { _firstOf, _sequence, FAIL, }
		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { oneOrMore(WSP), expression, }), }
		rules["firstOf"]		= sequence { expression, oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, zeroOrMore(sequence { oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, }), }

		rules["expression"]		= sequence { optional(predicate), firstOf { sequence { char('('), rule, char(')'), }, ruleName, literal, chars, macro, dot, }.withName("type"), optional(multiplicity), }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }
		rules["literal"]		= sequence { char('"'), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot('"'), }), char('"'), optional(char('i')), }
		rules["chars"]			= sequence { char('['), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot(']'), }), char(']'), optional(char('i')), }
		rules["macro"]			= sequence { char('\\'), oneOrMore(alphaChar), }
		rules["dot"]			= char('.')
		
		// built in rules
		rules["WSP"]			= spaceChar { it.useInResult = false; it.debug = false }
		rules["NL"]				= newLineChar { it.debug = false }
		rules["EOS"]			= eos { it.debug = false }
		rules["FAIL"]			= NoOpRule("PEG parse FAIL", false)
		
		return rules
	}
	
	// FIXME , Str? rootRuleName
	private Rule toRule(PegMatch? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		match.dump
		
		if (match.name == "rule") {
			match = match.matches.first
			
			rule := fromRule(match)
			
			return rule
		}
		
		throw UnsupportedErr()
	}

	private Rule fromRule(PegMatch match) {
		rule := null as Rule
		switch (match.name) {
			case "sequence":
				if (match.matches.size == 1)
					rule = fromExpression(match.matches.first)
				else {
					rules := match.matches.map { fromExpression(it) }
					rule = Rules.sequence(rules)
				}

			case "firstOf":
				rules := match.matches.map { fromExpression(it) }
				rule = Rules.firstOf(rules)
			
			default:
				throw UnsupportedErr("Unknown rule: ${match.name}")
		}
		return rule
	}
	
	private Rule fromExpression(PegMatch match) {
		if (match.name != "expression")
			throw ArgErr("Match should be 'expression', not '${match.name}'")

		exType	:= match["type"] as PegMatch
		multi	:= match["multiplicity"]?.matched
		pred	:= match["predicate"]?.matched
		exName	:= exType.matches.first.name
		exRule	:= null as Rule

		switch (exName) {
			case "rule"		: exRule = fromRule(exType.matches.first.matches.first)
//			case "ruleName"	: exRule = fromRuleName(exName)
			case "literal"	: exRule = StrRule.fromStr(match.matched)
			case "chars"	: exRule = CharRule.fromStr(match.matched)
			case "macro"	: exRule = fromMacro(match.matched)
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
	
	private Rule fromMacro(Str macro) {
		switch (macro[1..-1]) {
			case "s"		:
			case "white"	: return Rules.whitespaceChar
			case "S"		: return Rules.whitespaceChar(true)
			case "n"		: return Rules.newLineChar
			case "d"		:
			case "digit"	: return Rules.numChar
			case "D"		: return Rules.numChar(true)
			case "a"		:
			case "letter"	: return Rules.alphaChar
			case "A"		: return Rules.alphaChar(true)
			case "w"		: return Rules.wordChar
			case "W"		: return Rules.wordChar(true)
			case "upper"	: return Rules.charIn('A'..'Z')
			case "lower"	: return Rules.charIn('a'..'z')
			case "ident"	: return Rules.sequence { Rules.charRule("[a-zA-Z_]"), Rules.zeroOrMore(Rules.wordChar), }
		}
		throw UnsupportedErr("Unknown macro: $macro")
	}
	
	Rule parseRule(Str pattern) {
		toRule(Peg(pattern, rules["rule"]).match)
	}
	
	Rule parseGrammar(Str grammar, Str? rootRuleName) {
		toRule(Peg(grammar, rules["grammar"]).match)
	}
}
