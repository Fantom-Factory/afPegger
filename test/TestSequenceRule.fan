
internal class TestSequenceRule : Test, Rules {
	
	Void testSequence() {
		parser	:= Parser(sequence([anyNumChar, anyAlphaChar, anySpaceChar]))
		verify     (parser.parse("1a ".in).passed)
		verifyEq   (parser.parse("1a ".in).matched, "1a ")
		
		verifyFalse(parser.parse("1aa".in).passed)
		verifyFalse(parser.parse("1a" .in).passed)
		verifyFalse(parser.parse("1"  .in).passed)
		verifyFalse(parser.parse(""   .in).passed)

		verifyFalse(parser.parse("X1 ".in).passed)
		verifyFalse(parser.parse("19 ".in).passed)
		verifyFalse(parser.parse("1aX".in).passed)

		verify     (parser.parse("1a X".in).passed)
		verifyEq   (parser.parse("1a X".in).matched, "1a ")
	}
}
