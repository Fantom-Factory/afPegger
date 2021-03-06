
class TestLabels : Test, Rules {
	
	Void testNameIdentityCrisis() {
		// test rules can't be given multiple names
		g := PegGrammar().parseGrammar(
			"a = c 
			 c = ."
		).dumpToOut
		
		verifyEq(g.rules[0].name, "a")	// a <- . (!!!)
		verifyEq(g.rules[1].name, "c")	// a <- . (!!!)

		verifyEq(g.rules[0].expression, "c")
		verifyEq(g.rules[1].expression, ".")
	}

	Void testLabelIdentityCrisis() {
		g := PegGrammar().parseGrammar(
			"a = lab1:c
			 b = lab2:c 
			 c = ."
		).dumpToOut

		verifyEq(g.rules[0].name, "a")	// b <- lab1:c (!!!)
		verifyEq(g.rules[1].name, "b")	// b <- lab2:c
		verifyEq(g.rules[2].name, "c")	// c <- .

		verifyEq(g.rules[0].expression, "lab1:c")
		verifyEq(g.rules[1].expression, "lab2:c")
		verifyEq(g.rules[2].expression, ".")
	}

	Void testLabelsAreNotInherited() {
		g := PegGrammar().parseGrammar(
			"a = lab1:c b
			 b = lab2:c 
			 c = ."
		).dumpToOut

		verifyEq(g.rules[0].expression, "lab1:c b"	)	// a <- lab1:c lab2:b (!!!)
		verifyEq(g.rules[1].expression, "lab2:c"	)	// b <- lab2:c
		verifyEq(g.rules[2].expression, "."			)	// c <- .

		verifyEq(g.rules[0].expression, "lab1:c b")
		verifyEq(g.rules[1].expression, "lab2:c")
		verifyEq(g.rules[2].expression, ".")
	}

	Void testNamesCanHaveLabels() {
		g := PegGrammar().parseGrammar(
			"attributes      = attr:doubleQuoteAttr / attr:singleQuoteAttr
			 doubleQuoteAttr = '--'
			 singleQuoteAttr = '-'  "
		).dumpToOut
		
		match := g.firstRule.match("--").dumpToOut.firstMatch

		// these SHOULD be on the same rule 
		verifyEq(match.rule.label,	"attr")
		verifyEq(match.rule.name,	"doubleQuoteAttr")
	}
}
