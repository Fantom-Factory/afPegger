

@Js
internal class BnfGrammar : Rules {

	static Grammar bnfGrammar() {
		// todo - cache this grammer, mainly for testing
		grammar := `fan://afPegger/res/bnf.peg.txt`.toFile.readAllStr
		_grammar := Peg.parseGrammar(grammar)
		return _grammar
	}
	
	Grammar parseGrammar(Str grammar) {
		peg := Peg(grammar, bnfGrammar["rulelist"])
		return toGrammar(peg.match)
	}

	Rule parseRule(Str pattern) {
		peg := Peg(pattern, bnfGrammar["elements"])
		throw UnsupportedErr()
//		return toRule(peg.match, null)
	}
	
	// ---- Helper methods ----
	
	internal Grammar toGrammar(Match? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		if (match.name != "grammar")
			throw UnsupportedErr("Unknown rule: ${match.name}")
		
		newGrammar := Grammar()
		match.matches.each |ruleDef| {
			if (ruleDef.name != "ruleDef") 
				throw ParseErr("Not a ruleDef: ${ruleDef.name}")
				
			name := ruleDef["ruleName"].matched
			rule := toRule(ruleDef["rule"], newGrammar)
			rule.name = name
			newGrammar[name] = rule
		}
		return newGrammar.validate
	}

	private Rule toRule(Match? match, Grammar? newGrammar) {
		throw UnsupportedErr()
	}
}
