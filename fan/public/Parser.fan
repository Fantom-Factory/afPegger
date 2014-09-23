
class Parser {
	private Rule 		rootRule
	
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}
	
	Result parse(InStream in) {
//		try {
			ctx		:= PegCtx(rootRule, in)
			result	:= ctx.process(rootRule)
			if (result)
				ctx.rootResult.success
			return ctx.rootResult

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
