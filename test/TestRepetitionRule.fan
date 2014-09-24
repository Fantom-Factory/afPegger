
internal class TestRepetitionRule : Test, Rules {

	Void testOptional() {
		parser	:= Parser(optional(anyAlphaChar))
		verify     (parser.parse("X".in).passed)
		verifyEq   (parser.parse("X".in).matched, "X")

		verify     (parser.parse("1".in).passed)
		verifyEq   (parser.parse("1".in).matched, "")

		verify     (parser.parse("".in).passed)
		verifyEq   (parser.parse("".in).matched, "")

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "X")
	}

	Void testZeroOrMore() {
		parser	:= Parser(zeroOrMore(anyAlphaChar))
		verify     (parser.parse("X".in).passed)
		verifyEq   (parser.parse("X".in).matched, "X")

		verify     (parser.parse("1".in).passed)
		verifyEq   (parser.parse("1".in).matched, "")

		verify     (parser.parse("".in).passed)
		verifyEq   (parser.parse("".in).matched, "")

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "XX")

		verify     (parser.parse("XXXX".in).passed)
		verifyEq   (parser.parse("XXXX".in).matched, "XXXX")
	}

	Void testOneOrMore() {
		parser	:= Parser(oneOrMore(anyAlphaChar))
		verify     (parser.parse("X".in).passed)
		verifyEq   (parser.parse("X".in).matched, "X")

		verifyFalse(parser.parse("1".in).passed)

		verifyFalse(parser.parse("".in).passed)

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "XX")

		verify     (parser.parse("XXXX".in).passed)
		verifyEq   (parser.parse("XXXX".in).matched, "XXXX")
	}

	Void testAtLeast() {
		parser	:= Parser(atLeast(2, anyAlphaChar))
		verifyFalse(parser.parse("X".in).passed)

		verifyFalse(parser.parse("1".in).passed)

		verifyFalse(parser.parse("".in).passed)

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "XX")

		verify     (parser.parse("XXXX".in).passed)
		verifyEq   (parser.parse("XXXX".in).matched, "XXXX")
	}

	Void testAtMost() {
		parser	:= Parser(atMost(2, anyAlphaChar))
		verify     (parser.parse("X".in).passed)
		verifyEq   (parser.parse("X".in).matched, "X")

		verify     (parser.parse("1".in).passed)
		verifyEq   (parser.parse("1".in).matched, "")

		verify     (parser.parse("".in).passed)
		verifyEq   (parser.parse("".in).matched, "")

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "XX")

		verify     (parser.parse("XXXX".in).passed)
		verifyEq   (parser.parse("XXXX".in).matched, "XX")
	}
	
	Void testNTimes() {
		parser	:= Parser(nTimes(2, anyAlphaChar))
		verifyFalse(parser.parse("X".in).passed)

		verifyFalse(parser.parse("1".in).passed)

		verifyFalse(parser.parse("".in).passed)

		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "XX")

		verify     (parser.parse("XXXX".in).passed)
		verifyEq   (parser.parse("XXXX".in).matched, "XX")
	}
}
