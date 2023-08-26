
@Js
class TestPredicateRule : Test {

	Void testOnlyIf() {
		parser	:= Rules.onlyIf(Rules.alphaChar)
		verify     (parser.match("X")?.matched != null)
		verifyEq   (parser.match("X")?.matched, "")

		verifyFalse(parser.match("1")?.matched != null)

		// test rollback
		parser	= Rules.sequence([ Rules.onlyIf(Rules.alphaChar), Rules.anyChar ])
		parser	= Rules.sequence { Rules.onlyIf(Rules.alphaChar), Rules.anyChar, }
		verify     (parser.match("XX")?.matched != null)
		verifyEq   (parser.match("XX")?.matched, "X")
	}

	Void testOnlyIfNot() {
		parser	:= Rules.onlyIfNot( Rules.alphaChar)
		verify     (parser.match("9")?.matched != null)
		verifyEq   (parser.match("9")?.matched, "")

		verifyFalse(parser.match("X")?.matched != null)

		// test rollback
		parser	= Rules.sequence ([Rules.onlyIfNot(Rules.alphaChar), Rules.anyChar ])
		parser	= Rules.sequence { Rules.onlyIfNot(Rules.alphaChar), Rules.anyChar, }
		verify     (parser.match("99")?.matched != null)
		verifyEq   (parser.match("99")?.matched, "9")
	}
}
