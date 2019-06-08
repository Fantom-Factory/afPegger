
@Js
internal class PegGrammar : Rules {
	
	Rule rule() {
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
		
		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(WSP), char('='), zeroOrMore(WSP), oneOrMore(anyChar), firstOf { NL, EOS, }, }
		
//		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(WSP), char('='), zeroOrMore(WSP), rule, firstOf { NL, EOS, }, }
		rules["ruleName"]		= sequence { charIn('a'..'z'), zeroOrMore(alphaNumChar), }

//		rules["rule"]			= firstOf  { _firstOf, _sequence, FAIL, }
//		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { oneOrMore(WSP), expression, }), }
//		rules["firstOf"]		= sequence { expression, oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, zeroOrMore(sequence { oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, }), }
//
//		rules["expression"]		= sequence { optional(predicate), firstOf { sequence { char('('), rule, char(')'), }, ruleName, literal, chars, dot, }, optional(multiplicity), }
//		rules["predicate"]		= firstOf  { char('!'), char('&'), }
//		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }
//		rules["literal"]		= sequence { char('"'), anyCharNot('"'), char('"'), }	// TODO make specific
//		rules["chars"]			= sequence { char('['), anyCharNot(']'), char(']'), }	// TODO make specific
//		rules["dot"]			= char('.')
		
		// built in rules
		rules["WSP"]			= CharRule("[ \t]", false) |Int peek->Bool| { peek == ' ' || peek == '\t' } { it.debug = false }
		rules["NL"]				= newLineChar { it.debug = false }
		rules["EOS"]			= eos { it.debug = false }
		rules["FAIL"]			= NoOpRule("FAIL", false)
		
		return line
	}
}

internal class PegAstNode {
	
}
