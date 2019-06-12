
@Js
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser		:= anyChar
		verify		(parser.match("a") != null)
		verify		(parser.match(" ") != null)
		verifyFalse	(parser.match( "") != null)
	}

	Void testAnyCharOf() {
		parser		:= charOf("ab".chars)
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verifyFalse	(parser.match("c") != null)
	}

	Void testAnyCharNotOf() {
		parser		:= charNotOf("ab".chars)
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verify		(parser.match("c") != null)
	}

	Void testAnyCharInRange() {
		parser	:= charIn('b'..'d')
		verifyFalse	(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verify		(parser.match("d") != null)
		verifyFalse	(parser.match("e") != null)
	}

	Void testAnyCharNotInRange() {
		parser		:= charIn('b'..'d', true)
		verify		(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("c") != null)
		verifyFalse	(parser.match("d") != null)
		verify		(parser.match("e") != null)
	}

	Void testAnyAlphaChar() {
		parser		:= alphaChar
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verifyFalse	(parser.match("1") != null)
		verifyFalse	(parser.match("2") != null)
		verifyFalse	(parser.match(" ") != null)
	}

	Void testAnyNumChar() {
		parser		:= numChar
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse	(parser.match(" ") != null)
	}

	Void testAnyAlphaNumChar() {
		parser		:= alphaNumChar
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse (parser.match(" ") != null)
	}

	Void testAnySpaceChar() {
		parser		:= whitespaceChar
		verifyFalse (parser.match("a") != null)
		verifyFalse (parser.match("b") != null)
		verifyFalse (parser.match("1") != null)
		verifyFalse (parser.match("2") != null)
		verify		(parser.match(" ") != null)
	}

	Void testAnyNonSpaceChar() {
		parser		:= whitespaceChar(true)
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse (parser.match(" ") != null)
	}

	Void testCharClass() {
		parser		:= CharRule.fromStr("[a]")
		verify		(parser.match("a") != null)
		verifyFalse	(parser.match("A") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("B") != null)

		parser		 = CharRule.fromStr("[a]i")
		verify		(parser.match("a") != null)
		verify		(parser.match("A") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("B") != null)

		parser		 = CharRule.fromStr("[^a]i")
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("A") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("B") != null)

		parser		 = CharRule.fromStr("[ ]")
		verify		(parser.match(" ") != null)
		verifyFalse	(parser.match("A") != null)

		parser		 = CharRule.fromStr("[\n]")
		verify		(parser.match("\n") != null)
		verifyFalse	(parser.match("A") != null)

		parser		 = CharRule.fromStr("[^\n]")
		verifyFalse	(parser.match("\n") != null)
		verify		(parser.match("A") != null)

		parser		 = CharRule.fromStr("[b-d]")
		verifyFalse	(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verify		(parser.match("d") != null)
		verifyFalse	(parser.match("e") != null)
		verifyFalse	(parser.match("A") != null)
		verifyFalse	(parser.match("B") != null)
		verifyFalse	(parser.match("C") != null)
		verifyFalse	(parser.match("D") != null)
		verifyFalse	(parser.match("E") != null)

		parser		 = CharRule.fromStr("[b-d]i")
		verifyFalse	(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verify		(parser.match("d") != null)
		verifyFalse	(parser.match("e") != null)
		verifyFalse	(parser.match("A") != null)
		verify		(parser.match("B") != null)
		verify		(parser.match("C") != null)
		verify		(parser.match("D") != null)
		verifyFalse	(parser.match("E") != null)

		parser		 = CharRule.fromStr("[^b-d]i")
		verify		(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("c") != null)
		verifyFalse	(parser.match("d") != null)
		verify		(parser.match("e") != null)
		verify		(parser.match("A") != null)
		verifyFalse	(parser.match("B") != null)
		verifyFalse	(parser.match("C") != null)
		verifyFalse	(parser.match("D") != null)
		verify		(parser.match("E") != null)

		parser		= CharRule.fromStr("[\tb-dX-Z34]")
		verify		(parser.match("\t") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verify		(parser.match("X") != null)
		verify		(parser.match("Z") != null)
		verify		(parser.match("4") != null)
		verifyFalse	(parser.match("A") != null)
		verifyFalse	(parser.match(" ") != null)
		verifyFalse	(parser.match("9") != null)
	}
	
	Void testUnicode() {
		rule := CharRule.fromStr("[a\\u003Dz]")
		verifyEq(rule.expression, ("[a=z]"))
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, "=")
		verifyEq(rule.match("=")?.matched, "=")
		
		rule = Peg.parseRule("[a\\u003Dz]")
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, "=")
		verifyEq(rule.match("=")?.matched, "=")

		// test escaping the escape
		rule = CharRule.fromStr("[a\\\\u003Dz]")
		verifyEq(rule.expression, ("[a\\\\u003Dz]"))
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, null)
		verifyEq(rule.match("=")?.matched, null)
		verifyEq(rule.match("u")?.matched, "u")
		verifyEq(rule.match("\\")?.matched, "\\")
		verifyEq(rule.match("D")?.matched, "D")
		verifyEq(rule.match("A")?.matched, null)
		
		rule = Peg.parseRule("[a\\\\u003Dz]")
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, null)
		verifyEq(rule.match("=")?.matched, null)
		verifyEq(rule.match("u")?.matched, "u")
		verifyEq(rule.match("\\")?.matched, "\\")
		verifyEq(rule.match("D")?.matched, "D")
		verifyEq(rule.match("A")?.matched, null)
	}
}
