
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser	:= Parser(anyChar)
		verify     (parser.parse("a".in) != null)
		verify     (parser.parse(" ".in) != null)
		verifyFalse(parser.parse( "".in) != null)
	}

	Void testAnyCharOf() {
		parser	:= Parser(anyCharOf("ab".chars))
		verify     (parser.parse("a".in) != null)
		verify     (parser.parse("b".in) != null)
		verifyFalse(parser.parse("c".in) != null)
	}

	Void testAnyCharNotOf() {
		parser	:= Parser(anyCharNotOf("ab".chars))
		verifyFalse(parser.parse("a".in) != null)
		verifyFalse(parser.parse("b".in) != null)
		verify     (parser.parse("c".in) != null)
	}

	Void testAnyCharInRange() {
		parser	:= Parser(anyCharInRange('b'..'d'))
		verifyFalse(parser.parse("a".in) != null)
		verify     (parser.parse("b".in) != null)
		verify     (parser.parse("c".in) != null)
		verify     (parser.parse("d".in) != null)
		verifyFalse(parser.parse("e".in) != null)
	}

	Void testAnyCharNotInRange() {
		parser	:= Parser(anyCharNotInRange('b'..'d'))
		verify     (parser.parse("a".in) != null)
		verifyFalse(parser.parse("b".in) != null)
		verifyFalse(parser.parse("c".in) != null)
		verifyFalse(parser.parse("d".in) != null)
		verify     (parser.parse("e".in) != null)
	}

	Void testAnyAlphaChar() {
		parser	:= Parser(anyAlphaChar)
		verify     (parser.parse("a".in) != null)
		verify     (parser.parse("b".in) != null)
		verifyFalse(parser.parse("1".in) != null)
		verifyFalse(parser.parse("2".in) != null)
		verifyFalse(parser.parse(" ".in) != null)
	}

	Void testAnyNumChar() {
		parser	:= Parser(anyNumChar)
		verifyFalse(parser.parse("a".in) != null)
		verifyFalse(parser.parse("b".in) != null)
		verify     (parser.parse("1".in) != null)
		verify     (parser.parse("2".in) != null)
		verifyFalse(parser.parse(" ".in) != null)
	}

	Void testAnyAlphaNumChar() {
		parser	:= Parser(anyAlphaNumChar)
		verify     (parser.parse("a".in) != null)
		verify     (parser.parse("b".in) != null)
		verify     (parser.parse("1".in) != null)
		verify     (parser.parse("2".in) != null)
		verifyFalse(parser.parse(" ".in) != null)
	}

	Void testAnySpaceChar() {
		parser	:= Parser(anySpaceChar)
		verifyFalse(parser.parse("a".in) != null)
		verifyFalse(parser.parse("b".in) != null)
		verifyFalse(parser.parse("1".in) != null)
		verifyFalse(parser.parse("2".in) != null)
		verify     (parser.parse(" ".in) != null)
	}

	Void testAnyNonSpaceChar() {
		parser	:= Parser(anyNonSpaceChar)
		verify     (parser.parse("a".in) != null)
		verify     (parser.parse("b".in) != null)
		verify     (parser.parse("1".in) != null)
		verify     (parser.parse("2".in) != null)
		verifyFalse(parser.parse(" ".in) != null)
	}
}
