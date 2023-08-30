
@Js
internal class TestStrRules : Test {

	Void testStr() {
		parser		:= Rules.str("ever")
		verify     (parser.match("ever")?.toStr != null)
		verifyEq   (parser.match("ever")?.toStr, "ever")

		verifyFalse(parser.match(""         ) != null)
		verifyFalse(parser.match("wot"      ) != null)
		verifyFalse(parser.match("neverever") != null)
	}

	Void testStrNot() {
		parser		:= Rules.strNot("ever")

		verifyNull	(parser.match("ever"))
		verifyNull	(parser.match(""))

		verify		(parser.match("wot")?.toStr != null)
		verifyEq	(parser.match("wot")?.toStr, "wot")
		
		verify		(parser.match("wotever")?.toStr != null)
		verifyEq	(parser.match("wotever")?.toStr, "wot")

		verify		(parser.match("wotever2")?.toStr != null)
		verifyEq	(parser.match("wotever2")?.toStr, "wot")

		// test internals
		verifyEq   (parser.match("1ever")?.matched, "1")
		verifyEq   (parser.match("12ever")?.matched, "12")
		verifyEq   (parser.match("123ever")?.matched, "123")
		verifyEq   (parser.match("1234ever")?.matched, "1234")
		verifyEq   (parser.match("12345ever")?.matched, "12345")
		verifyEq   (parser.match("123456ever")?.matched, "123456")
		verifyEq   (parser.match("1234567ever")?.matched, "1234567")
		verifyEq   (parser.match("12345678ever")?.matched, "12345678")
		verifyEq   (parser.match("123456789ever")?.matched, "123456789")
		verifyEq   (parser.match("1234567890ever")?.matched, "1234567890")
	}
	
	Void testUnicode() {
		rule := StrRule.fromStr("\"--\\u003D--\"")	// \u003D is '='
		verifyEq(rule.expression, ("\"--=--\""))	// check 0x3D was converted to a char
		verifyEq(rule.match("--\u003D--").matched, "--=--")
		verifyEq(rule.match("--=--"		).matched, "--=--")
		
		rule = Peg.parseRule("\"------\\u003D--\"")	// test escape parsing
		verifyEq(rule.expression, ("\"------=--\""))
		verifyEq(rule.match("------\u003D--").matched, "------=--")
		verifyEq(rule.match("------=--"		).matched, "------=--")

		rule = Peg.parseRule("\"-\\u003D--\"")
		verifyEq(rule.expression, ("\"-=--\""))
		verifyEq(rule.match("-\u003D--").matched, "-=--")
		verifyEq(rule.match("-=--"		).matched, "-=--")

		// test escaping the escape
		rule = StrRule.fromStr("\"--\\\\u003D--\"")
		verifyEq(rule.expression, ("\"--\\\\u003D--\""))
		verifyEq(rule.match("--\u003D--"), null)
		verifyEq(rule.match("--=--"), null)
		verifyEq(rule.match("--\\u003D--").matched, "--\\u003D--")

		rule = Peg.parseRule("'--\\\\u003D--'")
		verifyEq(rule.expression, ("\"--\\\\u003D--\""))
		verifyEq(rule.match("--\u003D--"), null)
		verifyEq(rule.match("--=--"), null)
		verifyEq(rule.match("--\\u003D--").matched, "--\\u003D--")

		rule = Peg.parseRule("'\\uFEFF--'")	// dodgy start of string test
		verifyEq(rule.match("\uFEFF--")?.matched?.size, 3)
	}
}
