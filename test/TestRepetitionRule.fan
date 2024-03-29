
@Js
internal class TestRepetitionRule : Test {

	Void testOptional() {
		parser	:= Rules.optional(Rules.alphaChar)
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
		parser	:= Rules.zeroOrMore(Rules.alphaChar)
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
		parser	:= Rules.oneOrMore(Rules.alphaChar)
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
		parser	:= Rules.atLeast(2, Rules.alphaChar)
		verifyFalse(parser.match("X")?.matched != null)

		verifyFalse(parser.match("1")?.matched != null)

		verifyFalse(parser.match("")?.matched != null)

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XXXX")
	}

	Void testAtMost() {
		parser	:= Rules.atMost(2, Rules.alphaChar)
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
		parser	:= Rules.nTimes(2, Rules.alphaChar)
		verifyFalse(parser.match("X")?.matched != null)

		verifyFalse(parser.match("1")?.matched != null)

		verifyFalse(parser.match("")?.matched != null)

		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "XX")

		verify     (parser.match("XXXX")?.matched != null)
		verifyEq   (parser.match("XXXX")?.matched, "XX")
	
		verifyEq	(parser.definition, "root <- [a-zA-Z]{2}")
	}
	
	Void testParsing() {
		r := Peg.parseRule("'x'{1}")
		verifyEq(r.typeof, RepetitionRule#)
		verifyEq(r.definition, "\"x\"{1}")
		verifyEq(r->min, 1)
		verifyEq(r->max, 1)
		
		r = Peg.parseRule("'x'{1,}")
		verifyEq(r.typeof, RepetitionRule#)
		verifyEq(r.definition, "\"x\"+")
		verifyEq(r->min, 1)
		verifyEq(r->max, null)

		r = Peg.parseRule("'x'{1,3}")
		verifyEq(r.typeof, RepetitionRule#)
		verifyEq(r.definition, "\"x\"{1,3}")
		verifyEq(r->min, 1)
		verifyEq(r->max, 3)

		verifyEq(Peg("x", r).match.matched, "x")
		verifyEq(Peg("xx", r).match.matched, "xx")
		verifyEq(Peg("xxx", r).match.matched, "xxx")

		r = Peg.parseRule("'x'{,3}")
		verifyEq(r.typeof, RepetitionRule#)
		verifyEq(r.definition, "\"x\"{,3}")
		verifyEq(r->min, null)
		verifyEq(r->max, 3)
	}
}
