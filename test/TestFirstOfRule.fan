
@Js
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar, anySpaceChar]))
		verifyEq(parser.match("1".in), "1")
		verifyEq(parser.match("a".in), "a")
		verifyEq(parser.match(" ".in), " ")
	}

	Void testFirstOfFail() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar]))
		verifyFalse(parser.match(" ".in) != null)
	}
}
