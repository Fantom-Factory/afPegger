
@Js
internal class TestRepetitionRule : Test, Rules {

	Void testOptional() {
		parser	:= optional(alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "X")

		verify     (parser.match("1")?.matched != null)
		verifyEq   (parser.match("1")?.matched, "")

		verify     (parser.match("")?.matched != null)
		verifyEq   (parser.match("")?.matched, "")

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "X")
	}

	Void testZeroOrMore() {
		parser	:= zeroOrMore(alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "X")

		verify     (parser.match("1")?.matched != null)
		verifyEq   (parser.match("1")?.matched, "")

		verify     (parser.match("")?.matched != null)
		verifyEq   (parser.match("")?.matched, "")

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XXXX")
	}

	Void testOneOrMore() {
		parser	:= oneOrMore(alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "X")

		verifyFalse(parser.match("1")?.matched != null)

		verifyFalse(parser.match("")?.matched != null)

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XXXX")
	}

	Void testAtLeast() {
		parser	:= atLeast(2, alphaChar)
		verifyFalse(parser.match("X")?.matched != null)

		verifyFalse(parser.match("1")?.matched != null)

		verifyFalse(parser.match("")?.matched != null)

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XXXX")
	}

	Void testAtMost() {
		parser	:= atMost(2, alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "X")

		verify     (parser.match("1")?.matched != null)
		verifyEq   (parser.match("1")?.matched, "")

		verify     (parser.match("")?.matched != null)
		verifyEq   (parser.match("")?.matched, "")

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XX")
	}
	
	Void testNTimes() {
		parser	:= nTimes(2, alphaChar)
		verifyFalse(parser.match("X")?.matched != null)

		verifyFalse(parser.match("1")?.matched != null)

		verifyFalse(parser.match("")?.matched != null)

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XX")
	}
}
