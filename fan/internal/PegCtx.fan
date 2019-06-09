
** Handed to 'Rule' classes during the matching process. 
** 
** Only needed when you're implementing your own rules.
@Js
internal class PegCtx {
	private static const Log	logger		:= PegCtx#.pod.log
	private		Str				in
	private		Rule			rootRule
	private		Result[]		resultStack
	private		Result			rootResult	{ private set }
	 			Int				cur			{ private set }
	
	internal new make(Str in, Rule rootRule) {
		if (rootRule.name 	== null)
			rootRule.name 	= "root"
		this.in				= in
		this.rootRule		= rootRule
		this.resultStack	= Result[,]
		this.rootResult		= Result(rootRule, cur)
	}
	
	This clearResults() {
		resultStack	= Result[,]
		rootResult	= Result(rootRule, cur)
		return this
	}
	
	** Call to process a sub-rule.
	Bool process(Rule rule) {
		result	:= resultStack.isEmpty ? rootResult : Result(rule, cur)
		parent	:= resultStack.last		
		resultStack.push(result)
		
		if (logger.isDebug && !eos) {
			peek := in[cur..<(cur+22).min(in.size)]
			if (cur+22 < in.size)
				peek += "..."
			_log(result, "--> ${curRuleName} - Processing: ${rule.expression} with: ${peek.toCode(null)}")
		}
		
		try {
			passed := rule.doProcess(this)
			result.end(this)

			if (passed) {
				if (logger.isDebug) {
					log("Passed!")
					log("Matched: ${result.matchedStr(in).toCode}")
				}
				parent?.addResult(result)
				
			} else {
				if (logger.isDebug) {
					log("Failed.")
					if (result.matchedSize > 0)
						log("Could not match: ${result.matchedStr(in).toCode}")
				}
				result.rollback(this)
			}
			
//			// Logs look better without this...!?
//			if (logger.isDebug) { 
//				millis := (Duration.now - result.startTime).toMillis.toLocale("#,000")
//				_log(result, "<-- ${curRuleName} - Processed. [${millis}ms]")
//			}

			return passed

		} finally {
			resultStack.pop
		}
	}
	
	** Call to rollback the matching of any subrules. 
	Void rollbackTo(Int newCur) {
		cur = newCur
	}

	** Reads 1 character from the underlying input stream.
	Int readChar() {
		in.getSafe(cur++)
	}
	
	** Logs the given message to debug. It is formatted to be the same as the other Pegger debug messages. 
	Void log(Str msg) {
		if (logger.isDebug) {
			result := resultStack.peek ?: rootResult
			_log(result, msg)
		}
	}
	
	Bool eos() {
		cur >= in.size
	}

	PegMatch doSuccess() {
		rootResult.success(in)
		return rootResult.match(in)
	}

	private Void _log(Result result, Str msg) {
		if (result.rule.debug) {
			depth := resultStack.size
			if (!msg.startsWith("--> ") && !msg.startsWith("<-- "))
				msg = "  > ${curRuleName} - ${msg}"
			pad	:= "".justr(depth)
			logger.debug("[${depth.toStr.justr(3)}]${pad}${msg}")
		}
	}
	
	private Str curRuleName() {
		resultStack.eachrWhile { it.rule.name } ?: rootResult.rule.name
	}
}
