
@Js
internal class TestStrRules : Test, Rules {

	Void testStr() {
		parser	:= Parser(str("ever"))
		verify     (parser.match("ever".in) != null)
		verifyEq   (parser.match("ever".in), "ever")

		verifyFalse(parser.match("".in) != null)
		verifyFalse(parser.match("wot".in) != null)
		verifyFalse(parser.match("neverever".in) != null)

		// test rollbacks
		p1	:= Parser(str("wot"))
		p2	:= Parser(str("ever"))
		in	:= "woteverwotever".in
		
		verify     (p1.match(in) != null)
		verifyFalse(p1.match(in) != null)
		verify     (p2.match(in) != null)
		verifyFalse(p2.match(in) != null)
		verify     (p1.match(in) != null)
		verifyFalse(p1.match(in) != null)
		verify     (p2.match(in) != null)
		verifyFalse(p2.match(in) != null)
	}

	Void testStrNot() {
		parser	:= Parser(strNot("ever"))
		verifyFalse(parser.match("ever".in) != null)

		verifyFalse(parser.match("".in) != null)

		verify     (parser.match("wot".in) != null)
		verifyEq   (parser.match("wot".in), "wot")

		verify     (parser.match("wotever".in) != null)
		verifyEq   (parser.match("wotever".in), "wot")

		// test rollbacks
		p1	:= Parser(strNot("wot"))
		p2	:= Parser(strNot("ever"))
		in	:= "wotever".in
		verifyFalse(p1.match(in) != null)
		verify     (p2.match(in) != null)
		verifyFalse(p2.match(in) != null)
		verify     (p1.match(in) != null)
		
		// test internals
		verifyEq   (parser.match("1ever".in), "1")
		verifyEq   (parser.match("12ever".in), "12")
		verifyEq   (parser.match("123ever".in), "123")
		verifyEq   (parser.match("1234ever".in), "1234")
		verifyEq   (parser.match("12345ever".in), "12345")
		verifyEq   (parser.match("123456ever".in), "123456")
		verifyEq   (parser.match("1234567ever".in), "1234567")
		verifyEq   (parser.match("12345678ever".in), "12345678")
		verifyEq   (parser.match("123456789ever".in), "123456789")
		verifyEq   (parser.match("1234567890ever".in), "1234567890")
	}
}
