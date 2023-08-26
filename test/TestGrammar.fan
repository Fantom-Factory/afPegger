
class TestGrammar : Test {

	Void testProxyRules() {
		// bugfix - this used to cause a StackOverflowError
		Grammar.parseGrammar("rule1 = rule2\nrule2 = [=]\n")
	}
	
	Void testSquashedRules() {
		// LOOK! We can condense rules together!
		verifyDefs("a = [bc]+![de]\"wot\"(.)*",	"a <- [bc]+ ![de] \"wot\" .*")
	}
	
	Void testPrecedence() {
		// LOOK! I add the brackets in for you!
		verifyDefs("a = [bc] [de] / [ef] [fg]", "a <- ([bc] [de]) / ([ef] [fg])")
	}
	
	Void testExclude() {
		gram1 := PegGrammar().parseGrammar("a=(b / c)+\nb=[0-9]\nc=[a-z]")["a"]
		mach1 := gram1.match("123abc123")
		verifyNotNull(mach1["b"])

		gram2 := PegGrammar().parseGrammar("-a=(b / c)+\nb=[0-9]\nc=[a-z]")["a"]
		mach2 := gram2.match("123abc123")
		verifyNotNull(mach2["b"])
		
		gram3 := PegGrammar().parseGrammar("a=(b / c)+\n-b=[0-9]\nc=[a-z]")["a"]
		mach3 := gram3.match("123abc123")
		verifyNull(mach3["b"])
	}
	
	private Void verifyDefs(Str in, Str out := in) {
		defs := PegGrammar().parseGrammar(in)
		verifyEq(out, defs.definition.trim)
	}
}
