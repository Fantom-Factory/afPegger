
class Parser {
	private Rule 		rootRule
//	private PegInStream	pegStream
//	private InStream	in
	
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
//		this.pegStream	= PegInStream(in)
//		this.in			= in
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
