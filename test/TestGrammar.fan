
class TestGrammar : Test, Rules {
	
	Void testProxyRules() {
		// bugfix - this used to StackOverflowError
		Grammar.parseGrammar("rule1 = rule2\nrule2 = [=]\n")
	}
}
