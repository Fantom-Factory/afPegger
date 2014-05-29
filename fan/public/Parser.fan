
class Parser {
	
	private Rule 	rootRule
	private PegBuf	pegBuf
	
	new make(Rule rootRule, InStream in) {
		this.rootRule 	= rootRule
		this.pegBuf		= PegBuf(in)
	}
	
	Match? parse() {
		if (rootRule.matches(pegBuf))
			return rootRule.pass(pegBuf)
		rootRule.fail(pegBuf)
		return null
	}

	Void parseAll(Bool closeStream := true) {
		
	}
	
}
