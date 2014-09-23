
class PegCtx {
	private static const Log	logger		:= PegCtx#.pod.log
	private		InStream		in
	private		Result[]		resultStack	:= Result[,]
	internal	Result			rootResult
	
	internal new make(Rule rootRule, InStream in) {
		if (rootRule.name == null)
			rootRule.name = "Root Rule"
		this.rootResult	= Result(rootRule)
		this.in			= in
		
		logger.level = LogLevel.debug
	}
	
	Bool process(Rule rule) {
		result	:= resultStack.isEmpty ? rootResult : Result(rule)		
		_log(result, "--> ${result.rule.name} - Processing... ${rule.expression}")

		resultStack.push(result)		
		try {
			rule.doProcess(this)			
		} finally {
			resultStack.pop
		}
		if (result.passed && !resultStack.isEmpty)
			resultStack.peek.results.add(result)
		
		millis	:= (Duration.now - result.startTime).toMillis.toLocale("#,000")
		_log(result, "<-- ${result.rule.name} - Processed. [${millis}ms]")

		return result.passed
	}
	
	Void pass(Bool rulePassed) {
		log(rulePassed ? "Passed!" : "Failed. Rolling back.")
		resultStack.peek.passed = rulePassed
		if (!rulePassed)
			resultStack.peek.rollback
		else
			log("Matched ${matched.toCode}")
	}

	|->| rollbackFunc {
		get { resultStack.peek.rollbackFunc }
		set { resultStack.peek.rollbackFunc = it }
	}

	Str matched {
		get { resultStack.peek.matched }
		set {
			resultStack.peek.matchStr = it 
			log("${it.toCode} matched")
		}
	}
	
	private Void rollback() {
		log("Rolling back")
		resultStack.peek.rollback
	}
	
	Str? read(Int n) {
		if (n == 1)
			return in.readChar?.toChar
		read := Str.fromChars((0..<n).toList.map { in.readChar }.exclude { it == null })
		log("${read.toCode} read")
		return read
	}

	Void unread(Str? str) {
		str?.chars?.eachr { in.unreadChar(it) }
	}
	
	
	Void log(Str msg) {
		result := resultStack.peek ?: rootResult
		_log(result, msg)
	}

	Void _log(Result result, Str msg) {
		if (logger.isDebug && result.rule.name != null) {
			depth := resultStack.size
			if (msg.startsWith("--> ") || msg.startsWith("<-- "))
				depth++
			else
				msg = "  > ${result.rule.name} - ${msg}"
			pad	:= "".justr(depth)
			logger.debug("[${depth.toStr.justr(3)}]${pad}${msg}")
		}
	}
}
