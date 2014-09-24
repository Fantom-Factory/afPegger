
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= Parser(onlyIf(anyAlphaChar))
		verify     (parser.parse("X".in).passed)
		verifyEq   (parser.parse("X".in).matched, "")

		verifyFalse(parser.parse("1".in).passed)

		// test rollback
		parser	= Parser(sequence([onlyIf(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIf(anyAlphaChar), anyChar, })
		verify     (parser.parse("XX".in).passed)
		verifyEq   (parser.parse("XX".in).matched, "X")
	}

	Void testOnlyIfNot() {
		parser	:= Parser(onlyIfNot(anyAlphaChar))
		verify     (parser.parse("9".in).passed)
		verifyEq   (parser.parse("9".in).matched, "")

		verifyFalse(parser.parse("X".in).passed)

		// test rollback
		parser	= Parser(sequence([onlyIfNot(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIfNot(anyAlphaChar), anyChar, })
		verify     (parser.parse("99".in).passed)
		verifyEq   (parser.parse("99".in).matched, "9")
	}
}
