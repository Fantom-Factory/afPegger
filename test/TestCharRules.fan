
@Js
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser	:= Parser(anyChar)
		verify     (parser.match("a".in) != null)
		verify     (parser.match(" ".in) != null)
		verifyFalse(parser.match( "".in) != null)
	}

	Void testAnyCharOf() {
		parser	:= Parser(anyCharOf("ab".chars))
		verify     (parser.match("a".in) != null)
		verify     (parser.match("b".in) != null)
		verifyFalse(parser.match("c".in) != null)
	}

	Void testAnyCharNotOf() {
		parser	:= Parser(anyCharNotOf("ab".chars))
		verifyFalse(parser.match("a".in) != null)
		verifyFalse(parser.match("b".in) != null)
		verify     (parser.match("c".in) != null)
	}

	Void testAnyCharInRange() {
		parser	:= Parser(anyCharInRange('b'..'d'))
		verifyFalse(parser.match("a".in) != null)
		verify     (parser.match("b".in) != null)
		verify     (parser.match("c".in) != null)
		verify     (parser.match("d".in) != null)
		verifyFalse(parser.match("e".in) != null)
	}

	Void testAnyCharNotInRange() {
		parser	:= Parser(anyCharNotInRange('b'..'d'))
		verify     (parser.match("a".in) != null)
		verifyFalse(parser.match("b".in) != null)
		verifyFalse(parser.match("c".in) != null)
		verifyFalse(parser.match("d".in) != null)
		verify     (parser.match("e".in) != null)
	}

	Void testAnyAlphaChar() {
		parser	:= Parser(anyAlphaChar)
		verify     (parser.match("a".in) != null)
		verify     (parser.match("b".in) != null)
		verifyFalse(parser.match("1".in) != null)
		verifyFalse(parser.match("2".in) != null)
		verifyFalse(parser.match(" ".in) != null)
	}

	Void testAnyNumChar() {
		parser	:= Parser(anyNumChar)
		verifyFalse(parser.match("a".in) != null)
		verifyFalse(parser.match("b".in) != null)
		verify     (parser.match("1".in) != null)
		verify     (parser.match("2".in) != null)
		verifyFalse(parser.match(" ".in) != null)
	}

	Void testAnyAlphaNumChar() {
		parser	:= Parser(anyAlphaNumChar)
		verify     (parser.match("a".in) != null)
		verify     (parser.match("b".in) != null)
		verify     (parser.match("1".in) != null)
		verify     (parser.match("2".in) != null)
		verifyFalse(parser.match(" ".in) != null)
	}

	Void testAnySpaceChar() {
		parser	:= Parser(anySpaceChar)
		verifyFalse(parser.match("a".in) != null)
		verifyFalse(parser.match("b".in) != null)
		verifyFalse(parser.match("1".in) != null)
		verifyFalse(parser.match("2".in) != null)
		verify     (parser.match(" ".in) != null)
	}

	Void testAnyNonSpaceChar() {
		parser	:= Parser(anyNonSpaceChar)
		verify     (parser.match("a".in) != null)
		verify     (parser.match("b".in) != null)
		verify     (parser.match("1".in) != null)
		verify     (parser.match("2".in) != null)
		verifyFalse(parser.match(" ".in) != null)
	}
}
