
internal class TestLocation : Test {
	
	Void testLocation() {
		peg := Peg("x\n  xx\n    xxx\n      xxxx\n", "[x]+ [ \n]*")
		
		verifyEq(peg.match.location, [1,1])
		verifyEq(peg.match.location, [3,2])
		verifyEq(peg.match.location, [5,3])
		verifyEq(peg.match.location, [7,4])
		verifyEq(peg.match,			  null)
	}
}
