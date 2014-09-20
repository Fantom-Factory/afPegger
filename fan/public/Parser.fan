
class Parser {
	private Rule 	rootRule
	private PegCtx	pegCtx
	
	new make(Rule rootRule, InStream in) {
		this.rootRule 	= rootRule
		this.pegCtx		= PegCtx(in)
		
		// FIXME: walk roots to check for dups
	}
	
	Result parse() {
		result := rootRule.walk(pegCtx)
		if (result.passed)
			result.success()
		return result
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
	
	Str[] failures() {
		pegCtx.fails
	}
}
