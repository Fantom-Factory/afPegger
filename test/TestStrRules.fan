
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
//		verifyFalse(parser.parse("ever".in).passed)
//
//		verifyFalse(parser.parse("".in).passed)
//
//		verify     (parser.parse("wot".in).passed)
//		verifyEq   (parser.parse("wot".in).matched, "wot")
//
//		verify     (parser.parse("wotever".in).passed)
		verifyEq   (parser.parse("wotever".in).matched, "wot")

		// test rollbacks
		p1	:= Parser(strNot("wot"))
		p2	:= Parser(strNot("ever"))
		in	:= "wotever".in
		verifyFalse(p1.parse(in).passed)
		verify     (p2.parse(in).passed)
		verifyFalse(p2.parse(in).passed)
		verify     (p1.parse(in).passed)
		
		// test internals
		verifyEq   (parser.parse("1ever".in).matched, "1")
		verifyEq   (parser.parse("12ever".in).matched, "12")
		verifyEq   (parser.parse("123ever".in).matched, "123")
		verifyEq   (parser.parse("1234ever".in).matched, "1234")
		verifyEq   (parser.parse("12345ever".in).matched, "12345")
		verifyEq   (parser.parse("123456ever".in).matched, "123456")
		verifyEq   (parser.parse("1234567ever".in).matched, "1234567")
		verifyEq   (parser.parse("12345678ever".in).matched, "12345678")
		verifyEq   (parser.parse("123456789ever".in).matched, "123456789")
		verifyEq   (parser.parse("1234567890ever".in).matched, "1234567890")
	}
}
