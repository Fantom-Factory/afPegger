
@Js
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= Parser(onlyIf(alphaChar))
		verify     (parser.match("X") != null)
		verifyEq   (parser.match("X"), "")

		verifyFalse(parser.match("1") != null)

		// test rollback
		parser	= Parser(sequence([onlyIf(alphaChar), anyChar]))
		parser	= Parser(sequence { onlyIf(alphaChar), anyChar, })
		verify     (parser.match("XX") != null)
		verifyEq   (parser.match("XX"), "X")
	}

	Void testOnlyIfNot() {
		parser	:= Parser(onlyIfNot(alphaChar))
		verify     (parser.match("9") != null)
		verifyEq   (parser.match("9"), "")

		verifyFalse(parser.match("X") != null)

		// test rollback
		parser	= Parser(sequence([onlyIfNot(alphaChar), anyChar]))
		parser	= Parser(sequence { onlyIfNot(alphaChar), anyChar, })
		verify     (parser.match("99") != null)
		verifyEq   (parser.match("99"), "9")
	}
}
