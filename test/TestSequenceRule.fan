
internal class TestSequenceRule : Test, Rules {
	
	Void testSequence() {
		parser	:= Parser(sequence([anyNumChar, anyAlphaChar, anySpaceChar]))
		verify     (parser.parse("1a ".in) != null)
		verifyEq   (parser.parse("1a ".in), "1a ")
		
		verifyFalse(parser.parse("1aa".in) != null)
		verifyFalse(parser.parse("1a" .in) != null)
		verifyFalse(parser.parse("1"  .in) != null)
		verifyFalse(parser.parse(""   .in) != null)

		verifyFalse(parser.parse("X1 ".in) != null)
		verifyFalse(parser.parse("19 ".in) != null)
		verifyFalse(parser.parse("1aX".in) != null)

		verify     (parser.parse("1a X".in) != null)
		verifyEq   (parser.parse("1a X".in), "1a ")
	}
}
