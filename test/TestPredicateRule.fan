
@Js
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= Parser(onlyIf(anyAlphaChar))
		verify     (parser.match("X".in) != null)
		verifyEq   (parser.match("X".in), "")

		verifyFalse(parser.match("1".in) != null)

		// test rollback
		parser	= Parser(sequence([onlyIf(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIf(anyAlphaChar), anyChar, })
		verify     (parser.match("XX".in) != null)
		verifyEq   (parser.match("XX".in), "X")
	}

	Void testOnlyIfNot() {
		parser	:= Parser(onlyIfNot(anyAlphaChar))
		verify     (parser.match("9".in) != null)
		verifyEq   (parser.match("9".in), "")

		verifyFalse(parser.match("X".in) != null)

		// test rollback
		parser	= Parser(sequence([onlyIfNot(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIfNot(anyAlphaChar), anyChar, })
		verify     (parser.match("99".in) != null)
		verifyEq   (parser.match("99".in), "9")
	}
}
