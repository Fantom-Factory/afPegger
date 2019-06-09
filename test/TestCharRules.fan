
@Js
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser	:= Parser(anyChar)
		verify     (parser.match("a") != null)
		verify     (parser.match(" ") != null)
		verifyFalse(parser.match( "") != null)
	}

	Void testAnyCharOf() {
		parser	:= Parser(charOf("ab".chars))
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verifyFalse(parser.match("c") != null)
	}

	Void testAnyCharNotOf() {
		parser	:= Parser(charNotOf("ab".chars))
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verify     (parser.match("c") != null)
	}

	Void testAnyCharInRange() {
		parser	:= Parser(charIn('b'..'d'))
		verifyFalse(parser.match("a") != null)
		verify     (parser.match("b") != null)
		verify     (parser.match("c") != null)
		verify     (parser.match("d") != null)
		verifyFalse(parser.match("e") != null)
	}

	Void testAnyCharNotInRange() {
		parser	:= Parser(charIn('b'..'d', true))
		verify     (parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verifyFalse(parser.match("c") != null)
		verifyFalse(parser.match("d") != null)
		verify     (parser.match("e") != null)
	}

	Void testAnyAlphaChar() {
		parser	:= Parser(alphaChar)
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verifyFalse(parser.match("1") != null)
		verifyFalse(parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnyNumChar() {
		parser	:= Parser(numChar)
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verify     (parser.match("1") != null)
		verify     (parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnyAlphaNumChar() {
		parser	:= Parser(alphaNumChar)
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verify     (parser.match("1") != null)
		verify     (parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnySpaceChar() {
		parser	:= Parser(whitespaceChar)
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verifyFalse(parser.match("1") != null)
		verifyFalse(parser.match("2") != null)
		verify     (parser.match(" ") != null)
	}

	Void testAnyNonSpaceChar() {
		parser	:= Parser(whitespaceChar(true))
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verify     (parser.match("1") != null)
		verify     (parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testCharClass() {
		parser	:= Parser(CharRule.fromStr("[a]"))
		verify		(parser.matches("a"))
		verifyFalse	(parser.matches("A"))
		verifyFalse	(parser.matches("b"))
		verifyFalse	(parser.matches("B"))

		parser	 = Parser(CharRule.fromStr("[a]i"))
		verify		(parser.matches("a"))
		verify		(parser.matches("A"))
		verifyFalse	(parser.matches("b"))
		verifyFalse	(parser.matches("B"))

		parser	 = Parser(CharRule.fromStr("[^a]i"))
		verifyFalse	(parser.matches("a"))
		verifyFalse	(parser.matches("A"))
		verify		(parser.matches("b"))
		verify		(parser.matches("B"))

		parser	 = Parser(CharRule.fromStr("[ ]"))
		verify		(parser.matches(" "))
		verifyFalse	(parser.matches("A"))

		parser	 = Parser(CharRule.fromStr("[\n]"))
		verify		(parser.matches("\n"))
		verifyFalse	(parser.matches("A"))

		parser	 = Parser(CharRule.fromStr("[^\n]"))
		verifyFalse	(parser.matches("\n"))
		verify		(parser.matches("A"))

		parser	 = Parser(CharRule.fromStr("[b-d]"))
		verifyFalse	(parser.matches("a"))
		verify		(parser.matches("b"))
		verify		(parser.matches("c"))
		verify		(parser.matches("d"))
		verifyFalse	(parser.matches("e"))
		verifyFalse	(parser.matches("A"))
		verifyFalse	(parser.matches("B"))
		verifyFalse	(parser.matches("C"))
		verifyFalse	(parser.matches("D"))
		verifyFalse	(parser.matches("E"))

		parser	 = Parser(CharRule.fromStr("[b-d]i"))
		verifyFalse	(parser.matches("a"))
		verify		(parser.matches("b"))
		verify		(parser.matches("c"))
		verify		(parser.matches("d"))
		verifyFalse	(parser.matches("e"))
		verifyFalse	(parser.matches("A"))
		verify		(parser.matches("B"))
		verify		(parser.matches("C"))
		verify		(parser.matches("D"))
		verifyFalse	(parser.matches("E"))

		parser	 = Parser(CharRule.fromStr("[^b-d]i"))
		verify		(parser.matches("a"))
		verifyFalse	(parser.matches("b"))
		verifyFalse	(parser.matches("c"))
		verifyFalse	(parser.matches("d"))
		verify		(parser.matches("e"))
		verify		(parser.matches("A"))
		verifyFalse	(parser.matches("B"))
		verifyFalse	(parser.matches("C"))
		verifyFalse	(parser.matches("D"))
		verify		(parser.matches("E"))

		parser	 = Parser(CharRule.fromStr("[\tb-dX-Z34]"))
		verify		(parser.matches("\t"))
		verify		(parser.matches("b"))
		verify		(parser.matches("c"))
		verify		(parser.matches("X"))
		verify		(parser.matches("Z"))
		verify		(parser.matches("4"))
		verifyFalse	(parser.matches("A"))
		verifyFalse	(parser.matches(" "))
		verifyFalse	(parser.matches("9"))
	}
}


@Js
class Parser {
	private Rule 		rootRule
	
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}

	Str? match(Str in) {
		Peg(in, rootRule).matched
	}

	Bool matches(Str in) {
		Peg(in, rootRule).matches
	}
}
