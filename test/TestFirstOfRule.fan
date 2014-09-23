
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar, anySpaceChar]))
		verifyEq(parser.parse("1".in).matched, "1")
		verifyEq(parser.parse("a".in).matched, "a")
		verifyEq(parser.parse(" ".in).matched, " ")
	}

	Void testFirstOfFail() {
		parser	:= Parser(firstOf([anyNumChar, anyAlphaChar]))
		verifyFalse(parser.parse(" ".in).passed)
	}
}
