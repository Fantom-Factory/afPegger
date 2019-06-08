
@Js
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= Parser(firstOf([numChar.withName("num"), alphaChar.withName("alpha"), whitespaceChar.withName("sp")]))
		verifyEq(parser.match("1"), "1")
		verifyEq(parser.match("a"), "a")
		verifyEq(parser.match(" "), " ")
		verifyEq(parser.match("?"), null)
	}

	Void testFirstOfFail() {
		parser	:= Parser(firstOf([numChar, alphaChar]))
		verifyFalse(parser.match(" ") != null)
	}
}
