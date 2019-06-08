
@Js
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser	:= Parser(anyChar)
		verify     (parser.match("a") != null)
		verify     (parser.match(" ") != null)
		verifyFalse(parser.match( "") != null)
	}

	Void testAnyCharOf() {
		parser	:= Parser(anyCharOf("ab".chars))
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verifyFalse(parser.match("c") != null)
	}

	Void testAnyCharNotOf() {
		parser	:= Parser(anyCharNotOf("ab".chars))
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verify     (parser.match("c") != null)
	}

	Void testAnyCharInRange() {
		parser	:= Parser(anyCharInRange('b'..'d'))
		verifyFalse(parser.match("a") != null)
		verify     (parser.match("b") != null)
		verify     (parser.match("c") != null)
		verify     (parser.match("d") != null)
		verifyFalse(parser.match("e") != null)
	}

	Void testAnyCharNotInRange() {
		parser	:= Parser(anyCharNotInRange('b'..'d'))
		verify     (parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verifyFalse(parser.match("c") != null)
		verifyFalse(parser.match("d") != null)
		verify     (parser.match("e") != null)
	}

	Void testAnyAlphaChar() {
		parser	:= Parser(anyAlphaChar)
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verifyFalse(parser.match("1") != null)
		verifyFalse(parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnyNumChar() {
		parser	:= Parser(anyNumChar)
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verify     (parser.match("1") != null)
		verify     (parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnyAlphaNumChar() {
		parser	:= Parser(anyAlphaNumChar)
		verify     (parser.match("a") != null)
		verify     (parser.match("b") != null)
		verify     (parser.match("1") != null)
		verify     (parser.match("2") != null)
		verifyFalse(parser.match(" ") != null)
	}

	Void testAnySpaceChar() {
		parser	:= Parser(anySpaceChar)
		verifyFalse(parser.match("a") != null)
		verifyFalse(parser.match("b") != null)
		verifyFalse(parser.match("1") != null)
		verifyFalse(parser.match("2") != null)
		verify     (parser.match(" ") != null)
	}

	Void testAnyNonSpaceChar() {
		parser	:= Parser(anyNonSpaceChar)
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
