
** Handed to 'Rule' classes during the matching process. 
** 
** Only needed when you're implementing your own rules.
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
	}
	
	** Call to process a sub-rule.
	Bool process(Rule rule) {
		result	:= resultStack.isEmpty ? rootResult : Result(rule)
		parent	:= resultStack.last		
		resultStack.push(result)
		
		if (logger.isDebug)
			_log(result, "--> ${result.rule.name} - Processing... ${rule.expression}")
		
		try {
			result.passed = rule.doProcess(this)
			if (logger.isDebug)
				log(result.passed ? "Passed!" : "Failed. Rolling back.")

			if (result.passed) {
				// this isDebug saves 500ms on a FantomFactory parse! That 'matched()' took some time!
				if (logger.isDebug)
					log("Matched ${result.matched.toCode}")
				result.rollup
				
				parent?.addResult(result)
				
			} else {
				result.rollback(this)
			}
			
			if (logger.isDebug) { 
				millis := (Duration.now - result.startTime).toMillis.toLocale("#,000")
				_log(result, "<-- ${result.rule.name} - Processed. [${millis}ms]")
			}

		} finally {
			resultStack.pop
		}
		return result.passed
	}

	** Call when the Rule has matched a Str.  
	Void matched(Str? match) {
		resultStack.peek.matchStr = match 
		if (logger.isDebug) 
			log("${match?.toCode} matched")
	}
	
	** Call to rollback the matching of any subrules. 
	Void rollback(Str msg := "Rolling back") {
		log(msg)
		resultStack.peek.rollback(this)
	}
	
	** Reads 'n' characters from the underlying input stream.
	Str? read(Int n) {
		read := (Str?) null
		
		if (n == 1) {
			read = in.readChar?.toChar
		} else {
			strBuf := StrBuf(n)
			for (; n > 0; n--) {
				char := in.readChar
				if (char != null)
					strBuf.addChar(char)
			}
			read = strBuf.toStr
		}
		
		if (logger.isDebug && read != null)
			log("${read.toCode} read")
		return read
	}

	** Pushes back, or un-reads, the given string onto the underlying input stream.
	** Use when rolling back a rule.
	Void unread(Str? str) {
		if (str != null && !str.isEmpty) {
			if (logger.isDebug)
				log("${str.toCode} un-read")
			str.chars.eachr { in.unreadChar(it) }
		}
	}

	** Reads 1 character from the underlying input stream.
	Int? readChar() {
		read := in.readChar
		if (logger.isDebug && read != null)
			log("${read.toCode} read")
		return read
	}
	
	** Logs the given message to debug. It is formatted to be the same as the other Pegger debug messages. 
	Void log(Str msg) {
		result := resultStack.peek ?: rootResult
		_log(result, msg)
	}

	private Void _log(Result result, Str msg) {
		if (logger.isDebug && result.rule.name != null) {
			depth := resultStack.size
			if (!msg.startsWith("--> ") && !msg.startsWith("<-- "))
				msg = "  > ${result.rule.name} - ${msg}"
			pad	:= "".justr(depth)
			logger.debug("[${depth.toStr.justr(3)}]${pad}${msg}")
		}
	}
}
