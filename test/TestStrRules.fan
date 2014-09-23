
internal class TestStrRules : Test, Rules {

	Void testStr() {
		parser	:= Parser(str("ever"))
		verify     (parser.parse("ever".in).passed)
		verifyEq   (parser.parse("ever".in).matched, "ever")

		verifyFalse(parser.parse("".in).passed)
		verifyFalse(parser.parse("wot".in).passed)
		verifyFalse(parser.parse("neverever".in).passed)

		// test rollbacks
		p1	:= Parser(str("wot"))
		p2	:= Parser(str("ever"))
		in	:= "woteverwotever".in
		
		verify     (p1.parse(in).passed)
		verifyFalse(p1.parse(in).passed)
		verify     (p2.parse(in).passed)
		verifyFalse(p2.parse(in).passed)
		verify     (p1.parse(in).passed)
		verifyFalse(p1.parse(in).passed)
		verify     (p2.parse(in).passed)
		verifyFalse(p2.parse(in).passed)
	}

	Void testStrNot() {
		parser	:= Parser(strNot("ever"))
		verifyFalse(parser.parse("ever".in).passed)

		verifyFalse(parser.parse("".in).passed)

		verify     (parser.parse("wot".in).passed)
		verifyEq   (parser.parse("wot".in).matched, "wot")

		verify     (parser.parse("wotever".in).passed)
		verifyEq   (parser.parse("wotever".in).matched, "wot")

		// test rollbacks
		p1	:= Parser(strNot("wot"))
		p2	:= Parser(strNot("ever"))
		in	:= "wotever".in
		verifyFalse(p1.parse(in).passed)
		verify     (p2.parse(in).passed)
		verifyFalse(p2.parse(in).passed)
		verify     (p1.parse(in).passed)
	}
}
