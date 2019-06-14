
class TestGrammar : Test, Rules {
	
	Void testProxyRules() {
		// bugfix - this used to cause a StackOverflowError
		Grammar.parseGrammar("rule1 = rule2\nrule2 = [=]\n")
	}
	
	Void testSquashedRules() {
		// LOOK! We can condense rules together!
		verifyDefs("a = [bc]+![de]\"wot\"(.)*//naa",	"a <- [bc]+ ![de] \"wot\" .*")
	}
	
	Void testPrecedence() {
		// LOOK! I add the brackets in for you!
		verifyDefs("a = [bc] [de] / [ef] [fg]", "a <- ([bc] [de]) / ([ef] [fg])")
	}
	
	private Void verifyDefs(Str in, Str out := in) {
		defs := PegGrammar().parseGrammar(in)
		verifyEq(out, defs.definition.trim)
	}
}
