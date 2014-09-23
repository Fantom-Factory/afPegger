
class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser := Parser(firstOf([anyNumChar, anyAlphaChar, anySpaceChar]))
		verifyEq(parser.parse("1".in).matched, "1")
	}

}
