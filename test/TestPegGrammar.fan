
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
		verifyRule("\\n"		, "\"\\n\"")
		verifyRule("\\letter"	, "[a-zA-Z]")
		verifyRule("\\digit"	, "[0-9]")
		verifyRule("\\upper"	, "[A-Z]")
		verifyRule("\\lower"	, "[a-z]")
		verifyRule("\\white"	, "[ \\t\\n]")
		verifyRule("\\space"	, "[ \\t]")
		verifyRule("\\ident"	, "[a-zA-Z_] [a-zA-Z0-9_]*")
		verifyRule("\\eos"		, "\\eos")
		verifyRule("\\eol"		, "\\eol")
		verifyRule("\\err(FAIL)", "\\err(FAIL)")
		verifyRule("\\noop(TODO)","\\noop(TODO)")
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
		verifyDefs(" \n\n  \n  a  = [bc] [de] \n\n  \n  ", "a <- [bc] [de]")
		
		// comments
		fail()
	}
	
	Void testPegCanParseItself() {
//		Peg.debugOn

		defsIn  := PegGrammar.pegGrammar   .rules.join("\n") { it.definition }
		defsOut := Peg.parseGrammar(defsIn).rules.join("\n") { it.definition }

		echo
		PegGrammar.pegGrammar.definition { echo(it) }
		echo
		echo(defsOut)
		
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
