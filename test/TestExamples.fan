
class TestExamples : Test, Rules {
	
	Void testSimple() {
		input := "<<<Hello Mum>>>"
		rule  := "'<'+ name:[a-zA-Z ]+ '>'+"
		match := Peg(input, rule).match
		name  := match["name"]	// --> "Hello Mum"

        verifyEq(name.toStr, "Hello Mum")
	}
	
	Void testCalc() {
		walk := null as |Match, |Match|?, |Match|?|
		walk = |Match m, |Match|? startFn, |Match|? endFn| {
			startFn?.call(m)
			m.matches.each { walk(it, startFn, endFn) }
			endFn?.call(m)
		}

		defs := "
		         calc = ex ([ ]* op [ ]* ex)+
		         ex   = num / ('(' calc ')' )
		         num  = [0-9]+
		         op   = [+\\-*/]
		         "
		
		defs2 := "expr = num:[0-9]+ / ( '(' calc ')' )
		          calc = expr ([ ] op:[+\\-*/] [ ] expr)+"
		
		gram := Peg.parseGrammar(defs)
		res  := Peg("((2 + (12 - 3)) * (((15 / 3) - 2) * 3)) + 4", gram["calc"]).match
		
//		res.dump
		
		ops := [
			"+" : |Int a, Int b -> Int| { a + b },
			"-" : |Int a, Int b -> Int| { a - b },
			"*" : |Int a, Int b -> Int| { a * b },
			"/" : |Int a, Int b -> Int| { a / b }
		]
		
		result := null
		
		walk(res, null, |Match m| {
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
