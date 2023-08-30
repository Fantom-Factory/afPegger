
class TestLabels : Test {
	
	Void testNameIdentityCrisis() {
		// test rules can't be given multiple names
		g := PegGrammar().parseGrammar(
			"a = c 
			 c = ."
		)
		
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
		)

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
		)

		verifyEq(g.rules[0].expression, "(lab1:c) b")	// a <- lab1:c lab2:b (!!!)
		verifyEq(g.rules[1].expression, "lab2:c"	)	// b <- lab2:c
		verifyEq(g.rules[2].expression, "."			)	// c <- .
	}

	Void testNamesCanHaveLabels() {
		g := PegGrammar().parseGrammar(
			"attributes      = attr:doubleQuoteAttr / attr:singleQuoteAttr
			 doubleQuoteAttr = '--'
			 singleQuoteAttr = '-'  "
		)
		
		match := g.firstRule.match("--").firstMatch

		// these SHOULD be on the same rule 
		verifyEq(match.rule.label,	"attr")
		verifyEq(match.rule.name,	"doubleQuoteAttr")
	}
	
	Void testRuleRefsWithLabels() {
		grammar := PegGrammar().parseGrammar(
			"a  = '@' acme:b
			 -b = [x]+"
		)
		match	:= grammar.firstRule.match("@xxx")
		
		// RuleRefs weren't allowed labels 
		verifyEq(match.getMatch("acme")?.matched, "xxx")
		
		// verify that "b" is still excluded
		verifyFalse(match.debugStr.contains("b"))
		verifyNull(match.getMatch("b"))
	}

	Void testRuleRefsExcl() {
		grammar := PegGrammar().parseGrammar(
			"a  = '@' b
			 b = c
			 -c  = [x]+"
		)
		match	:= grammar.firstRule.match("@xxx")
		
		// RuleRefs.useInResult was *always* from ref rule
		verifyEq(match.getMatch("b")?.matched, "xxx")
	}
}
