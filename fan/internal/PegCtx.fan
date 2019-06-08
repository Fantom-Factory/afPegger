
** Handed to 'Rule' classes during the matching process. 
** 
** Only needed when you're implementing your own rules.
@Js
internal class PegCtx {
	private static const Log	logger		:= PegCtx#.pod.log
	private		Str				in
	private		Result[]		resultStack	:= Result[,]
				Result			rootResult	{ private set }
	 			Int				cur			{ private set }
	
	internal new make(Rule rootRule, Str in) {
		if (rootRule.name == null)
			rootRule.name = "root"
		this.rootResult	= Result(rootRule, 0)
		this.in			= in
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
			_log(result, "--> ${rule.name} - Processing: ${rule.expression} with: ${peek.toCode(null)}")
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
//				_log(result, "<-- ${result.rule.name} - Processed. [${millis}ms]")
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

	PegMatch doSuccess(Obj? ctx) {
		rootResult.success(in, ctx)
		return rootResult.match(in)
	}

	private Void _log(Result result, Str msg) {
		if (logger.isDebug && result.rule.name != null && result.rule.debug) {
			depth := resultStack.size
			if (!msg.startsWith("--> ") && !msg.startsWith("<-- "))
				msg = "  > ${result.rule.name} - ${msg}"
			pad	:= "".justr(depth)
			logger.debug("[${depth.toStr.justr(3)}]${pad}${msg}")
		}
	}
}
