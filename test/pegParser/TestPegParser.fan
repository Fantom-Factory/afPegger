
class TestParser : Test {
	
	Void testEmptyLine() {
		Peg#.pod.log.level = LogLevel.debug
		
		res:= parsePeg("   ")
		res = parsePeg("\n   ")
		res = parsePeg("   \n   ")
		res = parsePeg("   \n   \n")
	}

	Void testAnyChar() {
		rulesTxt :=
"""ruleDef			= ruleDefName WSP* ":" WSP* rule (NL / EOS)
   ruleDefName		= [a-z]i [a-z0-9]i*
   
   rule			= firstOf / sequence / FAIL
   sequence		= expression (WSP+ expression)*
   firstOf			= expression WSP+ "/" WSP+ expression (WSP+ "/" WSP+ expression)*
   
   expression		= predicate? ("(" rule ")" / ruleName / literal / chars / dot) multiplicity?
   predicate		= "!" / "&"
   multiplicity	= "*" / "+" / "?"
   ruleName		= [a-z]i [a-z0-9]i*
   literal			= ("\"" (("\" [\\"fnrt]) / [^"])+ "\"") / ("'" (("\" [\\'fnrt]) / [^'])+ "'")
   chars			= "[" "^"? (("\" [\\"fnrt]) / ([a-zA-Z0-9] "-" [a-zA-Z0-9]) / [a-zA-Z0-9])+ "]" "i"?
   dot				= "."
   
   
   WSP				= [ \t]
   """
		
		res := parsePeg(rulesTxt)
		
		echo(res.dump)
	}
	
	
	private PegMatch? parsePeg(Str in) {
		Peg(in, PegGrammar().rule).match
	}
	
}
