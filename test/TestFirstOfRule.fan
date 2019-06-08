
@Js
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= Parser(firstOf([anyNumChar.withName("num"), anyAlphaChar.withName("alpha"), anySpaceChar.withName("sp")]))
		verifyEq(parser.match("1"), "1")
		verifyEq(parser.match("a"), "a")
		verifyEq(parser.match(" "), " ")
		verifyEq(parser.match("?"), null)
	}

	Void testFirstOfFail() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar]))
		verifyFalse(parser.match(" ") != null)
	}
}
