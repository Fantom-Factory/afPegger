
** Handed to 'Rule' classes during the matching process. 
** 
** Only needed when you're implementing your own rules.
@Js
internal class PegCtx : RuleCtx {
	private static const Log	logger		:= PegCtx#.pod.log
	private		Str				in
	private		Rule			rootRule
	private		Result[]		resultStack
	private		Obj?			meta
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
		if ((in.size - newCur) < 0 || newCur > in.size)
			throw ArgErr("Bad offset value: ${newCur} - str.size = ${in.size}")
		if (newCur < 0)
			newCur = in.size - newCur
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
			this.meta = null
			passed := rule.doProcess(this)
			result.end(this)
			result.meta = this.meta
			
			// do NOT null out the meta straight away - let the caller have access to it
//			this.meta = null

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

	override Str? readStr(Int size) {
		str := peekStr(size)
		cur += (str?.size ?: 0)
		return str
	}

	override Int? peekChar(Int offset := 0) {
		peek := in.getSafe(cur + offset)
		return peek == 0 ? null : peek
	}

	override Str? peekStr(Int size) {
		try	  return in.getRange(cur..<cur+size)
		catch return null
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

	override PegParseErr parseErr(Str errMsg) {
		lineNum := 0; in.chars.eachRange(0..<cur.min(in.size)) { if (it == '\n') lineNum++ }
		srcCode := PegSrcSnippet(in)
		return PegParseErr(srcCode, lineNum + 1, errMsg)
	}
	
	override Obj? getMeta() {
		this.meta
	}
	
	override Void setMeta(Obj? meta) {
		this.meta = meta
	}
	
	Match doSuccess() {
		rootResult.match(null, in)
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
