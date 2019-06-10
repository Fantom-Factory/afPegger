
class TestExamples : Test, Rules {
	
	Void testSimple() {
        verifyEq(Peg("<HelloMum>", "'<' name:[a-zA-Z]+ '>'").match["name"].toStr, "HelloMum")
	}
	
	Void testCalc() {
		defs := "number     = [0-9]+
		         operator   = [+-*%]
		         expression = number / ( '(' calc ')' )
		         calc       = expression (\\s operator \\s expression)+"
		
	}
}
