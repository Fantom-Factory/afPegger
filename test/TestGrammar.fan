
class TestGrammar : Test, Rules {
	
	Void testProxyRules() {
		// bugfix - this used to cause a StackOverflowError
		Grammar.parseGrammar("rule1 = rule2\nrule2 = [=]\n")
	}
}
