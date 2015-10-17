
@Js
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar, anySpaceChar]))
		verifyEq(parser.parse("1".in), "1")
		verifyEq(parser.parse("a".in), "a")
		verifyEq(parser.parse(" ".in), " ")
	}

	Void testFirstOfFail() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar]))
		verifyFalse(parser.parse(" ".in) != null)
	}
}
