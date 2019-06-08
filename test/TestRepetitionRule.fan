
@Js
internal class TestRepetitionRule : Test, Rules {

	Void testOptional() {
		parser	:= Parser(optional(anyAlphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "X")

		verify     (parser.match("1") != null)
		verifyEq   (parser.match("1"), "")

		verify     (parser.match("") != null)
		verifyEq   (parser.match(""), "")

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "X")
	}

	Void testZeroOrMore() {
		parser	:= Parser(zeroOrMore(anyAlphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "X")

		verify     (parser.match("1") != null)
		verifyEq   (parser.match("1"), "")

		verify     (parser.match("") != null)
		verifyEq   (parser.match(""), "")

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "XX")

		verify     (parser.match("XXXX") != null)
		verifyEq   (parser.match("XXXX"), "XXXX")
	}

	Void testOneOrMore() {
		parser	:= Parser(oneOrMore(anyAlphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "X")

		verifyFalse(parser.match("1") != null)

		verifyFalse(parser.match("") != null)

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "XX")

		verify     (parser.match("XXXX") != null)
		verifyEq   (parser.match("XXXX"), "XXXX")
	}

	Void testAtLeast() {
		parser	:= Parser(atLeast(2, anyAlphaChar))
		verifyFalse(parser.match("X") != null)

		verifyFalse(parser.match("1") != null)

		verifyFalse(parser.match("") != null)

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "XX")

		verify     (parser.match("XXXX") != null)
		verifyEq   (parser.match("XXXX"), "XXXX")
	}

	Void testAtMost() {
		parser	:= Parser(atMost(2, anyAlphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "X")

		verify     (parser.match("1") != null)
		verifyEq   (parser.match("1"), "")

		verify     (parser.match("") != null)
		verifyEq   (parser.match(""), "")

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "XX")

		verify     (parser.match("XXXX") != null)
		verifyEq   (parser.match("XXXX"), "XX")
	}
	
	Void testNTimes() {
		parser	:= Parser(nTimes(2, anyAlphaChar))
		verifyFalse(parser.match("X") != null)

		verifyFalse(parser.match("1") != null)

		verifyFalse(parser.match("") != null)

		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "XX")

		verify     (parser.match("XXXX") != null)
		verifyEq   (parser.match("XXXX"), "XX")
	}
}
