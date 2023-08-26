
@Js
internal class TestFirstOfRule : Test {
	
	Void testFirstOf() {
		parser	:= Rules.firstOf([Rules.numChar.withLabel("num"), Rules.alphaChar.withLabel("alpha"), Rules.whitespaceChar.withLabel("sp")])
		verifyEq(parser.match("1")?.matched, "1")
		verifyEq(parser.match("a")?.matched, "a")
		verifyEq(parser.match(" ")?.matched, " ")
		verifyEq(parser.match("?")?.matched, null)
	}

	Void testFirstOfFail() {
		parser	:= Rules.firstOf([Rules.numChar, Rules.alphaChar])
		verifyFalse(parser.match(" ")?.matched != null)
	}
}
