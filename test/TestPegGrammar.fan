
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
		verifyRule("\\eos"		, "\\eos")
		verifyRule("\\eol"		, "\\eol")
		verifyRule("\\err(FAIL)", "\\err(FAIL)")
		verifyRule("\\noop(TODO)","\\noop(TODO)")
		
		// I don't like these, they're cryptic
//		verifyRule("\\d"		, "[0-9]")
//		verifyRule("\\s"		, "[ \\t\\n]")
//		verifyRule("\\w"		, "[a-zA-Z0-9_]")
//		verifyRule("\\a"		, "[a-zA-Z]")
//		verifyRule("\\n"		, "\"\\n\"")
//		verifyRule("\\sp"		, "[ \\t]")

		// and these are just plain ugly!
//		verifyRule("\\D"		, "[^0-9]")
//		verifyRule("\\S"		, "[^ \\t\\n]")
//		verifyRule("\\W"		, "[^a-zA-Z0-9_]")
//		verifyRule("\\A"		, "[^a-zA-Z]")
//		verifyRule("\\letter"	, "[a-zA-Z]")
//		verifyRule("\\digit"	, "[0-9]")
//		verifyRule("\\upper"	, "[A-Z]")
//		verifyRule("\\lower"	, "[a-z]")
//		verifyRule("\\white"	, "[ \\t\\n]")
//		verifyRule("\\space"	, "[ \\t]")
//		verifyRule("\\ident"	, "[a-zA-Z_] [a-zA-Z0-9_]*")

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
	
	Void testGrammar() {
		verifyDefs("eol = \\n / \\eos", "eol <- \"\\n\" / \\eos")

		// diff symbols
		verifyDefs("a  = [bc] [de]", "a <- [bc] [de]")
		verifyDefs("a <- [bc] [de]", "a <- [bc] [de]")
		
		// multi-defs
		verifyDefs("a <- [bc] [de]\nb <- [bc] [de]", "a <- [bc] [de]\nb <- [bc] [de]")
		
		// empty lines
		verifyDefs("  \n\n  \na = [bc] [de]\n\n  \n  ", "a <- [bc] [de]")
		
		// comments
		verifyDefs("// comment\n  # comment\na = [bc] [de]", "a <- [bc] [de]")
		verifyDefs("// comment\n  # comment\na = [bc] [de]\n // comment", "a <- [bc] [de]")
	}
	
	Void testComments() {
		// in particular this tests comment lines in the middle of rules, and that rules can span multiple lines
		
		// multi-line ruledef - space post newline to distunguish it from a new rule def 
		verifyDefs("a = b\n c\n d", "a = b c d")
		
		
	}
	
	Void testPegCanParseItself() {
		echo
		PegGrammar.pegGrammar.definition { echo(it) }

		defsIn  := PegGrammar.pegGrammar   .definition
		defsOut := Peg.parseGrammar(defsIn).definition
		verifyEq(defsIn, defsOut)
	}
	
	private Void verifyRule(Str in, Str out := in) {
		verifyEq(out, Peg.parseRule(in).expression)
	}
	
	private Void verifyDefs(Str in, Str out := in) {
		defs := PegGrammar().parseGrammar(in).definition.trim
		verifyEq(out, defs)
	}
}
