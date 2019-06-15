
class TestBnfTerminals : Test {
	
	Grammar? bnfGrammar
	
	Void testGrammar() {
		bnfGrammar = Bnf.bnfGrammar
		
//		Peg.debugOn
		verifyMatch("CR = %b1011",		"\r", "CR")
		verifyMatch("CR = %d13",		"\r", "CR")
		verifyMatch("CR = %x0D",		"\r", "CR")
		verifyMatch("CRLF = %d13.10",	"\r\n", "CRLF")

//		parse("command = \"command string\"")
		
	}
	
	
	Void verifyMatch(Str bnf, Str in, Str ruleName) {
		peg   := Peg(bnf, bnfGrammar["rulelist"])
		gram  := BnfGrammar().toGrammar(peg.match.dump)
		match := gram.firstRule.match(in)
		verifyEq(match.firstMatch.name, ruleName)
	}
}
