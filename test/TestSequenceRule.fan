
@Js
internal class TestSequenceRule : Test, Rules {
	
	Void testSequence() {
		parser	:= Parser(sequence([anyNumChar, anyAlphaChar, anySpaceChar]))
		verify     (parser.match("1a ") != null)
		verifyEq   (parser.match("1a "), "1a ")
		
		verifyFalse(parser.match("1aa") != null)
		verifyFalse(parser.match("1a" ) != null)
		verifyFalse(parser.match("1"  ) != null)
		verifyFalse(parser.match(""   ) != null)

		verifyFalse(parser.match("X1 ") != null)
		verifyFalse(parser.match("19 ") != null)
		verifyFalse(parser.match("1aX") != null)

		verify     (parser.match("1a X") != null)
		verifyEq   (parser.match("1a X"), "1a ")
	}
}
