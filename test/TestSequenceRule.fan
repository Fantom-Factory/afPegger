
@Js
internal class TestSequenceRule : Test, Rules {
	
	Void testSequence() {
		parser	:= Parser(sequence([anyNumChar, anyAlphaChar, anySpaceChar]))
		verify     (parser.match("1a ".in) != null)
		verifyEq   (parser.match("1a ".in), "1a ")
		
		verifyFalse(parser.match("1aa".in) != null)
		verifyFalse(parser.match("1a" .in) != null)
		verifyFalse(parser.match("1"  .in) != null)
		verifyFalse(parser.match(""   .in) != null)

		verifyFalse(parser.match("X1 ".in) != null)
		verifyFalse(parser.match("19 ".in) != null)
		verifyFalse(parser.match("1aX".in) != null)

		verify     (parser.match("1a X".in) != null)
		verifyEq   (parser.match("1a X".in), "1a ")
	}
}
