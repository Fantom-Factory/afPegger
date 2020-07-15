
@Js
internal class TestFirstOfRule : Test, Rules {
	
	Void testFirstOf() {
		parser	:= firstOf([numChar.withLabel("num"), alphaChar.withLabel("alpha"), whitespaceChar.withLabel("sp")])
		verifyEq(parser.match("1")?.matched, "1")
		verifyEq(parser.match("a")?.matched, "a")
		verifyEq(parser.match(" ")?.matched, " ")
		verifyEq(parser.match("?")?.matched, null)
	}

	Void testFirstOfFail() {
		parser	:= firstOf([numChar, alphaChar])
		verifyFalse(parser.match(" ")?.matched != null)
	}
}
