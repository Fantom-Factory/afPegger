
@Js
internal class TestRepetitionRule : Test, Rules {

	Void testOptional() {
		parser	:= Parser(optional(anyAlphaChar))
		verify     (parser.parse("X".in) != null)
		verifyEq   (parser.parse("X".in), "X")

		verify     (parser.parse("1".in) != null)
		verifyEq   (parser.parse("1".in), "")

		verify     (parser.parse("".in) != null)
		verifyEq   (parser.parse("".in), "")

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "X")
	}

	Void testZeroOrMore() {
		parser	:= Parser(zeroOrMore(anyAlphaChar))
		verify     (parser.parse("X".in) != null)
		verifyEq   (parser.parse("X".in), "X")

		verify     (parser.parse("1".in) != null)
		verifyEq   (parser.parse("1".in), "")

		verify     (parser.parse("".in) != null)
		verifyEq   (parser.parse("".in), "")

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "XX")

		verify     (parser.parse("XXXX".in) != null)
		verifyEq   (parser.parse("XXXX".in), "XXXX")
	}

	Void testOneOrMore() {
		parser	:= Parser(oneOrMore(anyAlphaChar))
		verify     (parser.parse("X".in) != null)
		verifyEq   (parser.parse("X".in), "X")

		verifyFalse(parser.parse("1".in) != null)

		verifyFalse(parser.parse("".in) != null)

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "XX")

		verify     (parser.parse("XXXX".in) != null)
		verifyEq   (parser.parse("XXXX".in), "XXXX")
	}

	Void testAtLeast() {
		parser	:= Parser(atLeast(2, anyAlphaChar))
		verifyFalse(parser.parse("X".in) != null)

		verifyFalse(parser.parse("1".in) != null)

		verifyFalse(parser.parse("".in) != null)

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "XX")

		verify     (parser.parse("XXXX".in) != null)
		verifyEq   (parser.parse("XXXX".in), "XXXX")
	}

	Void testAtMost() {
		parser	:= Parser(atMost(2, anyAlphaChar))
		verify     (parser.parse("X".in) != null)
		verifyEq   (parser.parse("X".in), "X")

		verify     (parser.parse("1".in) != null)
		verifyEq   (parser.parse("1".in), "")

		verify     (parser.parse("".in) != null)
		verifyEq   (parser.parse("".in), "")

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "XX")

		verify     (parser.parse("XXXX".in) != null)
		verifyEq   (parser.parse("XXXX".in), "XX")
	}
	
	Void testNTimes() {
		parser	:= Parser(nTimes(2, anyAlphaChar))
		verifyFalse(parser.parse("X".in) != null)

		verifyFalse(parser.parse("1".in) != null)

		verifyFalse(parser.parse("".in) != null)

		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "XX")

		verify     (parser.parse("XXXX".in) != null)
		verifyEq   (parser.parse("XXXX".in), "XX")
	}
}
