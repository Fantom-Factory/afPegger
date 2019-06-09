
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

		rules["expression"]		= sequence { optional(predicate), firstOf { sequence { char('('), rule, char(')'), }, ruleName, literal, chars, dot, }, optional(multiplicity), }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }
		rules["literal"]		= sequence { char('"'), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot('"'), }), char('"'), optional(char('i')), }
		rules["chars"]			= sequence { char('['), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot(']'), }), char(']'), optional(char('i')), }
		rules["dot"]			= char('.')
		
		// built in rules
		rules["WSP"]			= spaceChar { it.useInResult = false }
		rules["NL"]				= newLineChar { it.debug = false }
		rules["EOS"]			= eos { it.debug = false }
		rules["FAIL"]			= NoOpRule("FAIL", false)
		
		return rules
	}
	
	// FIXME , Str? rootRuleName
	private Rule toRule(PegMatch? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		match.dump
		
		if (match.name == "rule") {
			match = match.matches.first
			if (match.name == "sequence") {
				match = match.matches.first
				if (match.name == "expression") {
					match = match.matches.first
					if (match.name == "dot") {
						return Rules.anyChar
					}
					if (match.name == "chars") {
						return CharRule.fromStr(match.matched)
					}
					if (match.name == "literal") {
						return StrRule.fromStr(match.matched)
					}
				}
			}
		}
		
		throw UnsupportedErr()
	}

//	private Void mRule(PegMatch match) {
//		if 
//	}
	
	
	
	
	
	Rule parseRule(Str pattern) {
		toRule(Peg(pattern, rules["rule"]).match)
	}
	
	Rule parseGrammar(Str grammar, Str? rootRuleName) {
		toRule(Peg(grammar, rules["grammar"]).match)
	}
}

internal class PegAstNode {
	
}
