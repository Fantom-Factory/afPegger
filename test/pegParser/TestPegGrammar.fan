
class TestPegGrammar : Test {
	
	Void testDot() {
		verifyRule(".", ".")
	}
	
	Void testChars() {
		verifyRule("[a]"		, "\"a\"")
		verifyRule("[a]i"		, "\"a\"i")
		verifyRule("[^a]i")
		verifyRule("[abc]")
		verifyRule("[ ]"		, "\" \"")
		verifyRule("[\\\\]"		, "\"\\\\\"")
		verifyRule("[\\]]"		, "\"]\"")
		verifyRule("[\\]\\-]"	, "[\\]\\-]")
		verifyRule("[\\w]"		, "\"w\"")		// there's nothing special about w
		verifyRule("[\n]"		, "\"\\n\"")
		verifyRule("[\\n]"		, "\"\\n\"")
		verifyRule("[^\n]"		, "[^\\n]")
		verifyRule("[^\\n]"		, "[^\\n]")
		verifyRule("[b-d]")
		verifyRule("[b-d]i")
		verifyRule("[^b-d]i")
		verifyRule("[\tb-dX-Z34]", "[b-dX-Z\\t34]")
	}
	
	Void testLiteral() {
		verifyRule("\"h\"")
		verifyRule("\"hello\"")
		verifyRule("\"hel lo\"")
		verifyRule("\"hel\tlo\""	, "\"hel\\tlo\"")
		verifyRule("\"hel\\tlo\"")
		verifyRule("\"hel\\\"lo\"")	// man, fyck all this escaping! 
		verifyRule("\"h\"i")
		verifyRule("\"hello\"i")
	}

	Void testMacro() {
		verifyRule("\\d"		, "[0-9]")
		verifyRule("\\D"		, "[^0-9]")
		verifyRule("\\s"		, "[ \\t\\n]")
		verifyRule("\\S"		, "[^ \\t\\n]")
		verifyRule("\\w"		, "[a-zA-Z0-9_]")
		verifyRule("\\W"		, "[^a-zA-Z0-9_]")
		verifyRule("\\a"		, "[a-zA-Z]")
		verifyRule("\\A"		, "[^a-zA-Z]")
		verifyRule("\\n"		, "[\\n]")
		verifyRule("\\letter"	, "[a-zA-Z]")
		verifyRule("\\digit"	, "[0-9]")
		verifyRule("\\upper"	, "[A-Z]")
		verifyRule("\\lower"	, "[a-z]")
		verifyRule("\\white"	, "[ \\t\\n]")
		verifyRule("\\ident"	, "[a-zA-Z_] [a-zA-Z0-9_]*")
	}
	
	Void testMultiplicity() {
		verifyRule(".?")
		verifyRule(".+")
		verifyRule(".*")
	}
	
	Void testPredicate() {
		verifyRule("&.")
		verifyRule("!.")
	}
	
	Void testSequence() {
		verifyRule(". . .")

		verifyRule(". (\\d \\d) .", ". ([0-9] [0-9]) .")
	}
	
	Void testFirstOf() {
		verifyRule(". / . / .")

		verifyRule(". / (\\d / \\d) / .", ". / ([0-9] / [0-9]) / .")
	}
	
	
	
//	Void testEmptyLine() {
//		Peg#.pod.log.level = LogLevel.debug
//		
//		res:= parsePeg("   ")
//		res = parsePeg("\n   ")
//		res = parsePeg("   \n   ")
//		res = parsePeg("   \n   \n")
//	}
//
//	Void testAnyChar() {
//		rulesTxt :=
//"""ruleDef			= ruleDefName WSP* ":" WSP* rule (NL / EOS)
//   ruleDefName		= [a-z]i [a-z0-9]i*
//   
//   rule			= firstOf / sequence / FAIL
//   sequence		= expression (WSP+ expression)*
//   firstOf			= expression WSP+ "/" WSP+ expression (WSP+ "/" WSP+ expression)*
//   
//   expression		= predicate? ("(" rule ")" / ruleName / literal / chars / dot) multiplicity?
//   predicate		= "!" / "&"
//   multiplicity	= "*" / "+" / "?"
//   ruleName		= [a-z]i [a-z0-9]i*
//   literal			= ("\"" (("\" [\\"fnrt]) / [^"])+ "\"") / ("'" (("\" [\\'fnrt]) / [^'])+ "'")
//   chars			= "[" "^"? (("\" [\\"fnrt]) / ([a-zA-Z0-9] "-" [a-zA-Z0-9]) / [a-zA-Z0-9])+ "]" "i"?
//   dot				= "."
//   
//   
//   WSP				= [ \t]
//   """
//		
//		res := parsePeg(rulesTxt)
//	}
	
	private Void verifyRule(Str in, Str out := in) {
		verifyEq(out, Peg.parseRule(in).expression)
	}
	
//	private PegMatch? parseRule(Str in) {
//		Peg(in, PegGrammar().rule).match
//	}
//	
//	private PegMatch? parsePeg(Str in) {
//		Peg(in, PegGrammar().grammar).match
//	}
	
}
