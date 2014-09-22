
class Parser {
	private Rule 		rootRule
	private PegInStream	pegStream
	
	new make(Rule rootRule, InStream in) {
		this.rootRule 	= rootRule
		this.pegStream	= PegInStream(in)
	}
	
	Result parse() {
//		try {
			result := rootRule.match(PegCtx(pegStream))
			if (result.matched)
				result.success()
			return result

//		} catch (Err err) {
//			throw PegErr()
//		}
	}

//	Match[] parseAll(Bool closeStream := true) {
//		try {
//			matches := Match[,]
//			match := null
//			while ((match = parse) != null)
//				matches.add(match)
//			return matches
////		return RepetitionRule(0, null, rootRule).match(pegCtx).matches 
//		} finally if (closeStream) pegCtx.close
//	}

}
