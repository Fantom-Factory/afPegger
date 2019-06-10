
class TestExamples : Test, Rules {
	
	Void testSimple() {
		rule := "'<' name:[a-zA-Z]+ '>'"
		name := Peg("<HelloMum>", rule).match["name"]	// --> "Hello Mum"
        verifyEq(name.toStr, "HelloMum")
	}
	
	Void testCalc() {
		defs := "
		         calc = ex (\\s* op \\s* ex)+
		         ex   = num / ('(' calc ')')
		         num  = [0-9]+
		         op   = [+\\-*/]
		         "
		
		defs2 := "expr = num:[0-9]+ / ( '(' calc ')')
		          calc = expr (\\s op:[+\\-*/] \\s expr)+"
		
		gram := Peg.parseGrammar(defs)
		res  := Peg("((2 + (12 - 3)) * (((15 / 3) - 2) * 3)) + 4", gram["calc"]).match
		
		res.dump
		
		ops := [
			"+" : |Int a, Int b -> Int| { a + b },
			"-" : |Int a, Int b -> Int| { a - b },
			"*" : |Int a, Int b -> Int| { a * b },
			"/" : |Int a, Int b -> Int| { a / b }
		]
		
		result := null
		
		res.walk(null, |Match m| {
			if (m.name == "num" && m.parent != null)
				m.parent.data = ["num" : m.matched.toInt]

			if (m.name == "calc") {
				a := m.matches[0].data["num"]
				b := m.matches[2].data["num"]
				o := m.matches[1].matched
				c := ops[o](a, b)
				
//				echo("$a $o $b = $c")
				
				if (m.parent != null)
					m.parent.data = ["num" : c]
				else
					result = c
			}
		})
		
		echo("result: $result")
		
		verifyEq(result, 103)
	}
}
