

@Js
internal class AbnfGrammar : Rules {

	static Grammar abnfGrammar() {
//		rules					:= Grammar()
//		ruleName				:= rules["ruleName"]
//		ruleName				= firstOf(sq)
//		return rules.validate

		grammar := `fan://afPegger/res/abnf.peg.txt`.toFile.readAllStr
		_grammar := Peg.parseGrammar(grammar)
		return _grammar
	}
	
	Rule parseRule(Str pattern) {
		peg := Peg(pattern, abnfGrammar["rule"])
		throw UnsupportedErr()
//		return toRule(peg.match, null)
	}
	
	Grammar parseGrammar(Str grammar) {
		peg := Peg(grammar, abnfGrammar["grammar"])
		throw UnsupportedErr()
//		return toGrammar(peg.match)
	}
}
