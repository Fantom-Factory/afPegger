
@Js
internal class TestStrRules : Test, Rules {

	Void testStr() {
		parser	:= Parser(str("ever"))
		verify     (parser.match("ever") != null)
		verifyEq   (parser.match("ever"), "ever")

		verifyFalse(parser.match(""         ) != null)
		verifyFalse(parser.match("wot"      ) != null)
		verifyFalse(parser.match("neverever") != null)
	}

	Void testStrNot() {
		parser	:= Parser(strNot("ever"))

		verifyNull	(parser.match("ever"))
		verifyNull	(parser.match(""))

		verify		(parser.match("wot") != null)
		verifyEq	(parser.match("wot"), "wot")
		
		verify		(parser.match("wotever") != null)
		verifyEq	(parser.match("wotever"), "wot")

		verify		(parser.match("wotever2") != null)
		verifyEq	(parser.match("wotever2"), "wot")

		// test internals
		verifyEq   (parser.match("1ever"), "1")
		verifyEq   (parser.match("12ever"), "12")
		verifyEq   (parser.match("123ever"), "123")
		verifyEq   (parser.match("1234ever"), "1234")
		verifyEq   (parser.match("12345ever"), "12345")
		verifyEq   (parser.match("123456ever"), "123456")
		verifyEq   (parser.match("1234567ever"), "1234567")
		verifyEq   (parser.match("12345678ever"), "12345678")
		verifyEq   (parser.match("123456789ever"), "123456789")
		verifyEq   (parser.match("1234567890ever"), "1234567890")
	}
}
