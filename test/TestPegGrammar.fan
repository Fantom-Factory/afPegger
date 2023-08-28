
class TestPegGrammar : Test {
	
	override Void setup() {
		Peg.debugOn(false)
	}
	
	Void testPegCanParseItself() {
		echo
		PegGrammar.pegGrammar.definition { echo(it) }

		defsIn  := PegGrammar.pegGrammar   .definition
		defsOut := Peg.parseGrammar(defsIn).definition
		verifyEq(defsIn, defsOut)
	}
	
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
		verifyRule("\\sos"			, "\\sos")
		verifyRule("\\eos"			, "\\eos")
		verifyRule("\\sol"			, "\\sol")
		verifyRule("\\eol"			, "\\eol")
		verifyRule("\\upper"		, "\\upper")
		verifyRule("\\lower"		, "\\lower")
		verifyRule("\\alpha"		, "\\alpha")
		verifyRule("\\pass"			, "\\pass")
		verifyRule("\\fail"			, "\\fail")
		verifyRule("\\err(FAIL)"	, "\\err(FAIL)")
//		verifyRule("\\noop(false)"	, "\\noop(false)")
//		verifyRule("\\dump(HELLO)"	, "\\dump(HELLO)")
		
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
		verifyRule(". ([0-9] [0-9]) .", ". ([0-9] [0-9]) .")
	}
	
	Void testFirstOf() {
		verifyRule(". / . / .")
		verifyRule(". / ([0-9] / [0-9]) / .", ". / ([0-9] / [0-9]) / .")
	}
	
	Void testWhitespace() {
		verifyDefs("eol = [\\n] / \\eos", "eol <- \"\\n\" / \\eos")

		// def symbols
		verifyDefs("a  = [bc] [de]", "a <- [bc] [de]")
		verifyDefs("a <- [bc] [de]", "a <- [bc] [de]")
		
		// multi-defs
		verifyDefs("a <- [bc] [de]\nb <- [bc] [de]", "a <- [bc] [de]\nb <- [bc] [de]")
		
		// empty lines
		verifyDefs("  \n\n  \na = [bc] [ef]\n\n  \n  ", "a <- [bc] [ef]")
		
		// trailing whitespace
		verifyDefs("a <- [bc]   ", "a <- [bc]")
		
		// multi-line ruledef - space post newline to distinguish it from a new rule def 
		verifyDefs("a = [bc]\n [cd]\n [de]\n", "a <- [bc] [cd] [de]")
	}
	
	Void testStartOfStreamComments() {
		verifyDefs("// comment\n  # comment\n#comm\n\na = [bc] [de]", "a <- [bc] [de]")
	}
	
	Void testWholeLineComments() {
		// test combinations of comments appearing in random places - this is by FAR the hardest part of PEG grammar!

		// in particular this tests comment lines in the middle of rules, and that rules can span multiple lines
		verifyDefs("a = [bc]\n [cd] // comment1\n [de]\n", 				"a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n  [de]\n", 			"a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n   [de]\n", 			"a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n //comment2\n [de]\n",	"a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n //comment2\n  [de]\n","a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n //comment2\n [de]\n",	"a <- [bc] [cd] [de]")

		verifyDefs("a = [bc]\n\n # comm1\n\nb = [cd]",		"a <- [bc]\nb <- [cd]")
		verifyDefs("a = [bc]\n# comm1\nb = [cd]",			"a <- [bc]\nb <- [cd]")
		verifyDefs("a = [bc]\n # comm1\nb = [cd]",			"a <- [bc]\nb <- [cd]")
		verifyDefs("a = [bc]\n # comm1\n\nb = [cd]",		"a <- [bc]\nb <- [cd]")
		verifyDefs("a = [bc]\n # comm1\n#comm2\nb = [cd]",	"a <- [bc]\nb <- [cd]")

		// comments mid-rule NEED to be prefixed with space, given how complicated parsing comments are,
		// I'm happy with this, esp given how rare mid-rule comments are!
		// Okay, nevermind, I actually made it work!  :D
		verifyDefs("a = [bc]\n [cd] // comment1\n//comment2\n [de]\n",	"a <- [bc] [cd] [de]")
		verifyDefs("a = [bc]\n [cd] // comment1\n//comment2\n  [de]\n",	"a <- [bc] [cd] [de]")
	}
	
	Void testEndOfLineComments() {
		verifyDefs("a = [bc] [de] #comm\nb <- [bc] [de]", "a <- [bc] [de]\nb <- [bc] [de]")
	}
	
	Void testEndOfStreamComments() {
		verifyDefs("a = [bc] [de] ",				"a <- [bc] [de]")
		verifyDefs("a = [bc] [de]#comment",			"a <- [bc] [de]")
		verifyDefs("a = [bc] [de] #comment",		"a <- [bc] [de]")
		verifyDefs("a = [bc] [de] #comment\n",		"a <- [bc] [de]")
		verifyDefs("a = [bc] [de] #comment\n ",		"a <- [bc] [de]")
		verifyDefs("a = [bc] [de] #comment\n #e",	"a <- [bc] [de]")
		verifyDefs("a = [bc] [de]\n",				"a <- [bc] [de]")
		verifyDefs("a = [bc] [de]\n#comment",		"a <- [bc] [de]")
		verifyDefs("a = [bc] [de]\n // comment",	"a <- [bc] [de]")		
	}	
	
	Void testDupDefs() {
		verifyErrMsg(Err#, "Definition already defined: a") {
			PegGrammar().parseGrammar("a = . \na = .")
		}
	}
	
	private Void verifyRule(Str in, Str out := in) {
		verifyEq(out, Peg.parseRule(in).expression)
	}
	
	private Void verifyDefs(Str in, Str out := in) {
		defs := PegGrammar().parseGrammar(in)
		verifyEq(out, defs.definition.trim)
	}
}
