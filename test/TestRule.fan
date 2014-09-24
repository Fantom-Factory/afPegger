
class TestRule : Test {
	
	Void testWrapRuleName() {
		verifyEq(Rule.wrapRuleName(ExpRule("dude")), 			"dude")
		verifyEq(Rule.wrapRuleName(ExpRule("[ ]")), 			"[ ]")
		verifyEq(Rule.wrapRuleName(ExpRule("(dude)")), 			"(dude)")
		verifyEq(Rule.wrapRuleName(ExpRule("(wot) (ever)")), 	"((wot) (ever))")
		verifyEq(Rule.wrapRuleName(ExpRule("wot / ever")), 		"(wot / ever)")
		
		// TODO: broken wrapRuleName() cases
//		verifyEq(Rule.wrapRuleName(ExpRule("[a b]")), 			"[a b]")
//		verifyEq(Rule.wrapRuleName(ExpRule("[a b] [c d]")),		"([a b] [c d])")
	}
}

internal class ExpRule : Rule {
	override Str expression 
	new make(Str exp) {
		this.expression = exp
	}	
	override Void doProcess(PegCtx ctx) { }
}