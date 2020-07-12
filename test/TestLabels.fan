
class TestLabels : Test, Rules {
	
	Void testNameIdentityCrisis() {
		// test labels can't be given multiple names
		g := PegGrammar().parseGrammar(
			"a = c 
			 c = ."
		).dump
		
		verifyEq(g.rules[0].name, "a")
		verifyEq(g.rules[1].name, "c")
	}

	Void testLabelIdentityCrisis() {
		// test labels can't be given multiple names
		g := PegGrammar().parseGrammar(
			"a = lab1:c b
			 b = lab2:c 
			 c = ."
		).dump
		
		g.rules.each {
			echo("$it.typeof $it.label $it.name $it.hash")
		}
		
		verifyEq(g.rules[0].name, "a")
		verifyEq(g.rules[1].name, "b")
		verifyEq(g.rules[2].name, "c")
	}
}
