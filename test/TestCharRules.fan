
@Js
internal class TestCharRules : Test {
	
	Void testAnyChar() {
		parser		:= Rules.anyChar
		verify		(parser.match("a") != null)
		verify		(parser.match(" ") != null)
		verifyFalse	(parser.match( "") != null)
		verifyEq	(parser.expression, ".")
	}

	Void testAnyCharOf() {
		parser		:= Rules.charOf("ab".chars)
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verifyFalse	(parser.match("c") != null)
		verifyEq	(parser.expression, "[ab]")
	}

	Void testAnyCharNotOf() {
		parser		:= Rules.charNotOf("ab".chars)
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verifyEq	(parser.expression, "[^ab]")
	}

	Void testAnyCharInRange() {
		parser		:= Rules.charIn('b'..'d')
		verifyFalse	(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("c") != null)
		verify		(parser.match("d") != null)
		verifyFalse	(parser.match("e") != null)
		verifyEq	(parser.expression, "[b-d]")
	}

	Void testAnyCharNotInRange() {
		parser		:= Rules.charIn('b'..'d', true)
		verify		(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("c") != null)
		verifyFalse	(parser.match("d") != null)
		verify		(parser.match("e") != null)
		verifyEq	(parser.expression, "[^b-d]")
		
		// test unicode escapes
		nonAscii	:= Peg.parseGrammar("nonascii = [^\\u0020-\\u007e]").firstRule
		verifyEq	 (nonAscii.expression, "[^ -~]")
		verifyNotNull(nonAscii.match("é"))
		verifyNull	 (nonAscii.match("a"))
		verifyNull	 (nonAscii.match(" "))
		verifyNull	 (nonAscii.match("{"))
	}

	Void testAnyAlphaChar() {
		parser		:= Rules.alphaChar
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verifyFalse	(parser.match("1") != null)
		verifyFalse	(parser.match("2") != null)
		verifyFalse	(parser.match(" ") != null)
		verifyEq	(parser.expression, "[a-zA-Z]")
	}

	Void testAnyNumChar() {
		parser		:= Rules.numChar
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse	(parser.match(" ") != null)
		verifyEq	(parser.expression, "[0-9]")
	}

	Void testAnyAlphaNumChar() {
		parser		:= Rules.alphaNumChar
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse (parser.match(" ") != null)
		verifyEq	(parser.expression, "[a-zA-Z0-9]")
	}

	Void testAnySpaceChar() {
		parser		:= Rules.whitespaceChar
		verifyFalse (parser.match("a") != null)
		verifyFalse (parser.match("b") != null)
		verifyFalse (parser.match("1") != null)
		verifyFalse (parser.match("2") != null)
		verify		(parser.match(" ") != null)
		verifyEq	(parser.expression, "[ \\t\\n]")
	}

	Void testAnyNonSpaceChar() {
		parser		:= Rules.whitespaceChar(true)
		verify		(parser.match("a") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("1") != null)
		verify		(parser.match("2") != null)
		verifyFalse (parser.match(" ") != null)
		verifyEq	(parser.expression, "[^ \\t\\n]")
	}

	Void testCharClass() {
		parser		:= CharRule.fromStr("[a]")
		verify		(parser.match("a") != null)
		verifyFalse	(parser.match("A") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("B") != null)
		verifyEq	(parser.expression, "\"a\"")

		parser		= CharRule.fromStr("[a]i")
		verify		(parser.match("a") != null)
		verify		(parser.match("A") != null)
		verifyFalse	(parser.match("b") != null)
		verifyFalse	(parser.match("B") != null)
		verifyEq	(parser.expression, "\"a\"i")

		parser		= CharRule.fromStr("[^a]i")
		verifyFalse	(parser.match("a") != null)
		verifyFalse	(parser.match("A") != null)
		verify		(parser.match("b") != null)
		verify		(parser.match("B") != null)
		verifyEq	(parser.expression, "[^a]i")

		parser		= CharRule.fromStr("[ ]")
		verify		(parser.match(" ") != null)
		verifyFalse	(parser.match("A") != null)
		verifyEq	(parser.expression, "\" \"")

		parser		= CharRule.fromStr("[\n]")
		verify		(parser.match("\n") != null)
		verifyFalse	(parser.match("A") != null)
		verifyEq	(parser.expression, "\"\\n\"")

		parser		= CharRule.fromStr("[^\n]")
		verifyFalse	(parser.match("\n") != null)
		verify		(parser.match("A") != null)
		verifyEq	(parser.expression, "[^\\n]")

		parser		= CharRule.fromStr("[b-d]")
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
		verifyEq	(parser.expression, "[b-d]")

		parser		= CharRule.fromStr("[b-d]i")
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
		verifyEq	(parser.expression, "[b-d]i")

		parser		= CharRule.fromStr("[^b-d]i")
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
		verifyEq	(parser.expression, "[^b-d]i")

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
		verifyEq	(parser.expression, "[b-dX-Z\\t34]")

		// test escapes
		parser		= CharRule.fromStr("[\\]]")
		verify		(parser.match("]") != null)
		verifyFalse	(parser.match("A") != null)
		verifyEq	(parser.expression, "\"]\"")

		parser		= CharRule.fromStr("[\\]\\-]")
		verify		(parser.match("]") != null)
		verify		(parser.match("-") != null)
		verifyFalse	(parser.match("A") != null)
		verifyEq	(parser.expression, "[\\]\\-]")

		parser		= Peg.parseRule("[\\]\\-]")
		verifyEq	(parser.expression, "[\\]\\-]")

		parser		 = CharRule.fromStr("[^\\]]")
		verifyFalse	(parser.match("]") != null)
		verify		(parser.match("A") != null)
		verifyEq	(parser.expression, "[^\\]]")

		parser		 = CharRule.fromStr("[^\\]\\-]")
		verifyFalse	(parser.match("]") != null)
		verifyFalse	(parser.match("-") != null)
		verify		(parser.match("A") != null)
		verifyEq	(parser.expression, "[^\\]\\-]")
		
		parser		= CharRule.fromStr("[\n-a]")
		verifyEq	(parser.expression, "[\\n-a]")
	}
	
	Void testUnicode() {
		rule := CharRule.fromStr("[a\\u003Dz]")
		verifyEq(rule.expression, ("[a=z]"))
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, "=")
		verifyEq(rule.match("=")?.matched, "=")
		verifyEq(rule.expression, "[a=z]")
		
		rule = Peg.parseRule("[a\\u003Dz]")
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, "=")
		verifyEq(rule.match("=")?.matched, "=")
		verifyEq(rule.expression, "[a=z]")

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
		verifyEq(rule.expression, "[a\\\\u003Dz]")
		
		rule = Peg.parseRule("[a\\\\u003Dz]")
		verifyEq(rule.match("z")?.matched, "z")
		verifyEq(rule.match("\u003D")?.matched, null)
		verifyEq(rule.match("=")?.matched, null)
		verifyEq(rule.match("u")?.matched, "u")
		verifyEq(rule.match("\\")?.matched, "\\")
		verifyEq(rule.match("D")?.matched, "D")
		verifyEq(rule.match("A")?.matched, null)
		verifyEq(rule.expression, "[a\\\\u003Dz]")
	}
}
