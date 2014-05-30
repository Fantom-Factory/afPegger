
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

	Match[] parseAll(Bool closeStream := true) {
		try return AtLeastRule(0, rootRule).match(pegBuf).matches 
		finally if (closeStream) pegBuf.close
	}
	
}
