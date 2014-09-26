
internal class TestStrRules : Test, Rules {

	Void testStr() {
		parser	:= Parser(str("ever"))
		verify     (parser.parse("ever".in) != null)
		verifyEq   (parser.parse("ever".in), "ever")

		verifyFalse(parser.parse("".in) != null)
		verifyFalse(parser.parse("wot".in) != null)
		verifyFalse(parser.parse("neverever".in) != null)

		// test rollbacks
		p1	:= Parser(str("wot"))
		p2	:= Parser(str("ever"))
		in	:= "woteverwotever".in
		
		verify     (p1.parse(in) != null)
		verifyFalse(p1.parse(in) != null)
		verify     (p2.parse(in) != null)
		verifyFalse(p2.parse(in) != null)
		verify     (p1.parse(in) != null)
		verifyFalse(p1.parse(in) != null)
		verify     (p2.parse(in) != null)
		verifyFalse(p2.parse(in) != null)
	}

	Void testStrNot() {
		parser	:= Parser(strNot("ever"))
		verifyFalse(parser.parse("ever".in) != null)

		verifyFalse(parser.parse("".in) != null)

		verify     (parser.parse("wot".in) != null)
		verifyEq   (parser.parse("wot".in), "wot")

		verify     (parser.parse("wotever".in) != null)
		verifyEq   (parser.parse("wotever".in), "wot")

		// test rollbacks
		p1	:= Parser(strNot("wot"))
		p2	:= Parser(strNot("ever"))
		in	:= "wotever".in
		verifyFalse(p1.parse(in) != null)
		verify     (p2.parse(in) != null)
		verifyFalse(p2.parse(in) != null)
		verify     (p1.parse(in) != null)
		
		// test internals
		verifyEq   (parser.parse("1ever".in), "1")
		verifyEq   (parser.parse("12ever".in), "12")
		verifyEq   (parser.parse("123ever".in), "123")
		verifyEq   (parser.parse("1234ever".in), "1234")
		verifyEq   (parser.parse("12345ever".in), "12345")
		verifyEq   (parser.parse("123456ever".in), "123456")
		verifyEq   (parser.parse("1234567ever".in), "1234567")
		verifyEq   (parser.parse("12345678ever".in), "12345678")
		verifyEq   (parser.parse("123456789ever".in), "123456789")
		verifyEq   (parser.parse("1234567890ever".in), "1234567890")
	}
}
