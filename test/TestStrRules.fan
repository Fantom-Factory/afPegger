
internal class TestStrRules : Test, Rules {

	Void testStr() {
		parser	:= Parser(str("ever"))
		verify     (parser.parse("ever".in).passed)
		verifyEq   (parser.parse("ever".in).matched, "ever")

		verifyFalse(parser.parse("wot".in).passed)

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

	
//	static Rule str(Str string, Bool ignoreCase := true) {
//		StrRule(string.toCode) |Str? peek->Bool| { ignoreCase ? string.equalsIgnoreCase(peek) : string.equals(peek) }
//	}
//	
//	static Rule anyStrNot(Str string, Bool ignoreCase := true) {
}
