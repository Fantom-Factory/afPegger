
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= Parser(onlyIf(anyAlphaChar))
		verify     (parser.parse("X".in) != null)
		verifyEq   (parser.parse("X".in), "")

		verifyFalse(parser.parse("1".in) != null)

		// test rollback
		parser	= Parser(sequence([onlyIf(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIf(anyAlphaChar), anyChar, })
		verify     (parser.parse("XX".in) != null)
		verifyEq   (parser.parse("XX".in), "X")
	}

	Void testOnlyIfNot() {
		parser	:= Parser(onlyIfNot(anyAlphaChar))
		verify     (parser.parse("9".in) != null)
		verifyEq   (parser.parse("9".in), "")

		verifyFalse(parser.parse("X".in) != null)

		// test rollback
		parser	= Parser(sequence([onlyIfNot(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIfNot(anyAlphaChar), anyChar, })
		verify     (parser.parse("99".in) != null)
		verifyEq   (parser.parse("99".in), "9")
	}
}
