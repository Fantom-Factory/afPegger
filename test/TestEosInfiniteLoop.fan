
class TestEosInfiniteLoop : Test {
	
	Void testInfiniteLoop() {
		// blank is a standard thought of matching empty lines that may, or may not, end with \n or \eos
		// the problem is that blank* enters an infinite loop as it doesn't actually consume anything
		//
		// In the general case, it's impossible to solve as the loop *could* be inside a predicate.
		//
		// But in the common case, we can easily check for \eos within the RepetitionRule loop
		
		lines := "xxxx\n\nyyyy\n\nzzzz"
		match := Peg.parseGrammar(
			"root  = (line blank*)+
			 line  = [a-z]+
			 blank = [ \t]* ('\n' / \\eos)"
		).firstRule.match(lines).dump
		
		match.contains("line")
		match.contains("blank")
	}	
}
