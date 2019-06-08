
class TestParseCharRule : Test {
	
	Void testAnyChar() {

		
	}
	
	
	private PegMatch? parsePeg(Str in) {
		Peg(in, PegGrammar().rule).match
	}
	
}
