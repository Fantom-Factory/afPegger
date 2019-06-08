
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
}
