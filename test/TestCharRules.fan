
internal class TestCharRules : Test, Rules {
	
	Void testAnyChar() {
		parser	:= Parser(anyChar)
		verify     (parser.parse("a".in).passed)
		verify     (parser.parse(" ".in).passed)
		verifyFalse(parser.parse( "".in).passed)
	}

	Void testAnyCharOf() {
		parser	:= Parser(anyCharOf("ab".chars))
		verify     (parser.parse("a".in).passed)
		verify     (parser.parse("b".in).passed)
		verifyFalse(parser.parse("c".in).passed)
	}

	Void testAnyCharNotOf() {
		parser	:= Parser(anyCharNotOf("ab".chars))
		verifyFalse(parser.parse("a".in).passed)
		verifyFalse(parser.parse("b".in).passed)
		verify     (parser.parse("c".in).passed)
	}

	Void testAnyCharInRange() {
		parser	:= Parser(anyCharInRange('b'..'d'))
		verifyFalse(parser.parse("a".in).passed)
		verify     (parser.parse("b".in).passed)
		verify     (parser.parse("c".in).passed)
		verify     (parser.parse("d".in).passed)
		verifyFalse(parser.parse("e".in).passed)
	}

	Void testAnyCharNotInRange() {
		parser	:= Parser(anyCharNotInRange('b'..'d'))
		verify     (parser.parse("a".in).passed)
		verifyFalse(parser.parse("b".in).passed)
		verifyFalse(parser.parse("c".in).passed)
		verifyFalse(parser.parse("d".in).passed)
		verify     (parser.parse("e".in).passed)
	}

	Void testAnyAlphaChar() {
		parser	:= Parser(anyAlphaChar)
		verify     (parser.parse("a".in).passed)
		verify     (parser.parse("b".in).passed)
		verifyFalse(parser.parse("1".in).passed)
		verifyFalse(parser.parse("2".in).passed)
		verifyFalse(parser.parse(" ".in).passed)
	}

	Void testAnyNumChar() {
		parser	:= Parser(anyNumChar)
		verifyFalse(parser.parse("a".in).passed)
		verifyFalse(parser.parse("b".in).passed)
		verify     (parser.parse("1".in).passed)
		verify     (parser.parse("2".in).passed)
		verifyFalse(parser.parse(" ".in).passed)
	}

	Void testAnyAlphaNumChar() {
		parser	:= Parser(anyAlphaNumChar)
		verify     (parser.parse("a".in).passed)
		verify     (parser.parse("b".in).passed)
		verify     (parser.parse("1".in).passed)
		verify     (parser.parse("2".in).passed)
		verifyFalse(parser.parse(" ".in).passed)
	}

	Void testAnySpaceChar() {
		parser	:= Parser(anySpaceChar)
		verifyFalse(parser.parse("a".in).passed)
		verifyFalse(parser.parse("b".in).passed)
		verifyFalse(parser.parse("1".in).passed)
		verifyFalse(parser.parse("2".in).passed)
		verify     (parser.parse(" ".in).passed)
	}

	Void testAnyNonSpaceChar() {
		parser	:= Parser(anyNonSpaceChar)
		verify     (parser.parse("a".in).passed)
		verify     (parser.parse("b".in).passed)
		verify     (parser.parse("1".in).passed)
		verify     (parser.parse("2".in).passed)
		verifyFalse(parser.parse(" ".in).passed)
	}
}
