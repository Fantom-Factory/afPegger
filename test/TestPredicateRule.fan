
@Js
class TestPredicateRule : Test, Rules {

	Void testOnlyIf() {
		parser	:= onlyIf(alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "")

		verifyFalse(parser.match("1")?.matched != null)

		// test rollback
		parser	= sequence([onlyIf(alphaChar), anyChar])
		parser	= sequence { onlyIf(alphaChar), anyChar, }
		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "X")
	}

	Void testOnlyIfNot() {
		parser	:= onlyIfNot(alphaChar)
		verify     (parser.match("9")?.matched != null)
		verifyEq   (parser.match("9")?.matched, "")

		verifyFalse(parser.match("X")?.matched != null)

		// test rollback
		parser	= sequence([onlyIfNot(alphaChar), anyChar])
		parser	= sequence { onlyIfNot(alphaChar), anyChar, }
		verify     (parser.match("99")?.matched != null)
		verifyEq   (parser.match("99")?.matched, "9")
	}
}
