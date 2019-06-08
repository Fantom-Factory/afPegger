
@Js
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= Parser(onlyIf(anyAlphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "")

		verifyFalse(parser.match("1") != null)

		// test rollback
		parser	= Parser(sequence([onlyIf(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIf(anyAlphaChar), anyChar, })
		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "X")
	}

	Void testOnlyIfNot() {
		parser	:= Parser(onlyIfNot(anyAlphaChar))
		verify     (parser.match("9") != null)
		verifyEq   (parser.match("9"), "")

		verifyFalse(parser.match("X") != null)

		// test rollback
		parser	= Parser(sequence([onlyIfNot(anyAlphaChar), anyChar]))
		parser	= Parser(sequence { onlyIfNot(anyAlphaChar), anyChar, })
		verify     (parser.match("99") != null)
		verifyEq   (parser.match("99"), "9")
	}
}
