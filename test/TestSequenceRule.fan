
@Js
internal class TestSequenceRule : Test {
	
	Void testSequence() {
		parser	:= Rules.sequence([Rules.numChar, Rules.alphaChar, Rules.whitespaceChar])
		verify     (parser.match("1a ")?.matched != null)
		verifyEq   (parser.match("1a ")?.matched, "1a ")
		
		verifyFalse(parser.match("1aa")?.matched != null)
		verifyFalse(parser.match("1a" )?.matched != null)
		verifyFalse(parser.match("1"  )?.matched != null)
		verifyFalse(parser.match(""   )?.matched != null)

		verifyFalse(parser.match("X1 ")?.matched != null)
		verifyFalse(parser.match("19 ")?.matched != null)
		verifyFalse(parser.match("1aX")?.matched != null)

		verify     (parser.match("1a X")?.matched != null)
		verifyEq   (parser.match("1a X")?.matched, "1a ")
	}
}
