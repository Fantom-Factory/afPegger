
class TestBnfTerminals : Test {
	
	Grammar? bnfGrammar := Bnf.bnfGrammar

	Void testNumbers() {
//		Peg.debugOn
		verifyDef("cr = %b1101",		"cr = \"\\r\"")
		verifyDef("cr = %d13",			"cr = \"\\r\"")
		verifyDef("cr = %x0D",			"cr = \"\\r\"")
		verifyDef("crLF = %d13.10",		"crLF = \"\\r\\n\"")

		verifyDef("dig = %x30-39", 							"dig = [0-9]")
		verifyDef("char-line = %x0D.0A %x20-7E %x0D.0A",	"char-line = \"\\r\\n\" [ -~] \"\\r\\n\"")
		verifyDef("rulename =  %d97 %d98 %d99",				"rulename = \"a\" \"b\" \"c\"")
		verifyDef("rulename =  %d97.98.99",					"rulename = \"abc\"")
	}

	Void testStrings() {
		verifyDef("command = \"command string\"", "command = \"command string\"i")
		verifyDef("rulename = \"abc\"",		"rulename = \"abc\"i")
		verifyDef("rulename = \"aBc\"",		"rulename = \"aBc\"i")
		verifyDef("rulename = %i\"aBc\"",	"rulename = \"aBc\"i")
		verifyDef("rulename = %s\"aBc\"",	"rulename = \"aBc\"")
	}

	Void testConcatenation() {
		verifyDef("mumble = %x61 %x62 %x63",	"mumble = \"a\" \"b\" \"c\"")
	}

	Void testAlternation() {
		verifyDef("a = ALPHA (ALPHA / DIGIT) DIGIT",	"a = [a-zA-Z] ([a-zA-Z] / [0-9]) [0-9]")
		verifyDef("a = ALPHA DIGIT / DIGIT ALPHA",		"a = ([a-zA-Z] [0-9]) / ([0-9] [a-zA-Z])")
	}
	
	Void testRepetition() {
		verifyDef("a = *<DIGIT>",	 "a = [0-9]*")
		verifyDef("a = *<DIGIT>",	 "a = [0-9]*")
		verifyDef("a = 1*<DIGIT>",	 "a = [0-9]+")
		verifyDef("a = 3*3<DIGIT>",	 "a = [0-9]{3,3}")
		verifyDef("a = 2<DIGIT>",	 "a = [0-9]{2,2}")
		verifyDef("a = 1*2<DIGIT>",	 "a = [0-9]{1,2}")
	}
	
	Void testOptional() {
		verifyDef("a = [DIGIT]",		 "a = [0-9]?")
		verifyDef("a = [DIGIT DIGIT]",	 "a = ([0-9] [0-9])?")
	}
	
	Void verifyDef(Str bnfGram, Str pegGram) {
		peg   := Peg(bnfGram, bnfGrammar["grammar"])
		gram  := BnfGrammar().toGrammar(peg.match.dump).dump.definition.trimEnd.replace("<-", "=")
		verifyEq(gram, pegGram)
	}
}
