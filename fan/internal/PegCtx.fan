
** Handed to 'Rule' classes during the matching process. 
** 
** Only needed when you're implementing your own rules.
@Js
internal class PegCtx : RuleCtx {
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
	
	** Returns the current position in the underlying input stream.
	override Int currentPos() {
		cur
	}
	
	** Rolls back the underlying input stream to the given position. 
	override Void rollbackToPos(Int newCur) {
		cur = newCur
	}
	
	** Call to process a sub-rule.
	override Bool process(Rule rule) {
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
	
	** Reads 1 character from the underlying input stream.
	override Int readChar() {
		in.getSafe(cur++)
	}
	
	** Logs the given message to debug. It is formatted to be the same as the other Pegger debug messages. 
	override Void log(Str msg) {
		if (logger.isDebug) {
			result := resultStack.peek ?: rootResult
			_log(result, msg)
		}
	}
	
	override Bool sos() { cur == 0 }

	** Returns 'true' if end-of-stream is reached. 
	override Bool eos() { cur >= in.size }
	
	override Str str() { in }

	Match doSuccess() {
		rootResult.match(null, in)
	}

	override PegParseErr parseErr(Str errMsg) {
		lineNum := 0; in.chars.eachRange(0..<cur.min(in.size)) { if (it == '\n') lineNum++ }
		srcCode := SrcCodeSnippet(in)
		return PegParseErr(srcCode, lineNum + 1, errMsg)
	}
	
	private Void _log(Result result, Str msg) {
		if (doLog) {
			depth := resultStack.size
			if (!msg.startsWith("--> ") && !msg.startsWith("<-- "))
				msg = "  > ${curRuleName} - ${msg}"
			pad	:= Str.spaces(depth)
			logger.debug("[${depth.toStr.justr(3)}]${pad}${msg}")
		}
	}
	
	private Bool doLog() {
		resultStack.all { it.rule.debug  }
	}
	
	private Str curRuleName() {
		rule := resultStack.peek.rule
		return (rule.name ?: rule.label) ?: rule.typeName
	}
}
