
class Parser {
	
	private Rule 	rootRule
	private PegBuf	pegBuf
	
	new make(Rule rootRule, InStream in) {
		this.rootRule 	= rootRule
		this.pegBuf		= PegBuf(in)
	}
	
	Match? parse() {
		rootRule.match(pegBuf)
	}

	Void parseAll(Bool closeStream := true) {
		// TODO
	}
	
}
