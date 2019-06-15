
class TestBnf : Test {
	
	Grammar? grammar
	
	Void testGrammar() {
		grammar = Bnf.bnfGrammar
		
		// these parse but don't show the last rule
//		parse("CR = %d13 ; comm")
//		parse("CR = %d13 ; comm\n")
//		parse("CR = %d13 ; comm\n;comm")
//		parse("CR = %d13;comm\n;comm")
//		parse("CR = %d13 ; com1\nDF = %hFF\n ")
//		parse("CR = %d13 ; com1\n ; com2\nDF = %hFF\n ")
		
		
//		Peg.debugOn
		
//		
//		parse("a = elem (foo / bar) blat")
//		//  matches (elem foo blat) or (elem bar blat), and
//
//		// FIXME
////		parse("a = elem foo / bar blat")
//		// matches (elem foo) or (bar blat).
//		
//		parse("a = *<element>")
//		parse("a = 1*<element>")
//		parse("a = 3*3<element>")
//		parse("a = 1*2<element>")
//		parse("a = 2<element>")	//n
		
		parse(`fan://afPegger/res/abnf.txt`.toFile.readAllStr)
	}
	
	
	Void parse(Str bnf) {
		Peg(bnf, grammar["grammar"]).match.dump
	}
}
