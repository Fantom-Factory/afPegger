
@Js
internal class TestRepetitionRule : Test, Rules {

	Void testOptional() {
		parser	:= Parser(optional(anyAlphaChar))
		verify     (parser.match("X".in) != null)
		verifyEq   (parser.match("X".in), "X")

		verify     (parser.match("1".in) != null)
		verifyEq   (parser.match("1".in), "")

		verify     (parser.match("".in) != null)
		verifyEq   (parser.match("".in), "")

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "X")
	}

	Void testZeroOrMore() {
		parser	:= Parser(zeroOrMore(anyAlphaChar))
		verify     (parser.match("X".in) != null)
		verifyEq   (parser.match("X".in), "X")

		verify     (parser.match("1".in) != null)
		verifyEq   (parser.match("1".in), "")

		verify     (parser.match("".in) != null)
		verifyEq   (parser.match("".in), "")

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "XX")

		verify     (parser.match("XXXX".in) != null)
		verifyEq   (parser.match("XXXX".in), "XXXX")
	}

	Void testOneOrMore() {
		parser	:= Parser(oneOrMore(anyAlphaChar))
		verify     (parser.match("X".in) != null)
		verifyEq   (parser.match("X".in), "X")

		verifyFalse(parser.match("1".in) != null)

		verifyFalse(parser.match("".in) != null)

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "XX")

		verify     (parser.match("XXXX".in) != null)
		verifyEq   (parser.match("XXXX".in), "XXXX")
	}

	Void testAtLeast() {
		parser	:= Parser(atLeast(2, anyAlphaChar))
		verifyFalse(parser.match("X".in) != null)

		verifyFalse(parser.match("1".in) != null)

		verifyFalse(parser.match("".in) != null)

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "XX")

		verify     (parser.match("XXXX".in) != null)
		verifyEq   (parser.match("XXXX".in), "XXXX")
	}

	Void testAtMost() {
		parser	:= Parser(atMost(2, anyAlphaChar))
		verify     (parser.match("X".in) != null)
		verifyEq   (parser.match("X".in), "X")

		verify     (parser.match("1".in) != null)
		verifyEq   (parser.match("1".in), "")

		verify     (parser.match("".in) != null)
		verifyEq   (parser.match("".in), "")

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "XX")

		verify     (parser.match("XXXX".in) != null)
		verifyEq   (parser.match("XXXX".in), "XX")
	}
	
	Void testNTimes() {
		parser	:= Parser(nTimes(2, anyAlphaChar))
		verifyFalse(parser.match("X".in) != null)

		verifyFalse(parser.match("1".in) != null)

		verifyFalse(parser.match("".in) != null)

		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "XX")

		verify     (parser.match("XXXX".in) != null)
		verifyEq   (parser.match("XXXX".in), "XX")
	}
}
