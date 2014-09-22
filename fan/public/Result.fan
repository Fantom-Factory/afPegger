
class Result {
	private Log log	:= Result#.pod.log
	
	** The name of the rule that created this 'Result'.
	Str? 		ruleName
	
	Str? 		matchStr
	Result[]?	results
	|->|?		rollbackFunc
	|->|?		successFunc
	LogRec[]?	logs		:= LogRec[,]

	
	internal new make(Str? ruleName) {
		this.ruleName = ruleName		
	}

	Void failed(Str? name, Str desc) {
		if (name == null)
			debug(" - failed - $desc")
		else
			debug("'$name' failed - $desc")		
	}

	Void passed(Str? name, Str desc) {
		msg := matchStr ?: desc
		if (name == null)
			debug(" - matched $desc")
		else
			info("'$name' matched $desc")
	}
	
	Void debug(Str msg) {
		logs.add(LogRec(DateTime.now, LogLevel.debug, ruleName ?: Str.defVal, msg))
		log.info(msg.toCode(null))
	}

	Void info(Str msg) {
		logs.add(LogRec(DateTime.now, LogLevel.info, ruleName, msg))
		log.warn(msg.toCode(null))
	}

	Str[] msgs() {
		(results?.map { it.msgs } ?: [,]).addAll(logs.findAll { it.level >= LogLevel.info }.map { formatLog(it) }).flatten
	}

	Str[] allMsgs() {
		(results?.map { it.allMsgs } ?: [,]).addAll(logs.map { formatLog(it) }).flatten
	}
	
	
	Void success() {
		if (ruleName != null)
			info("'$ruleName' is successful!'")
		// func should exist if we're calling success
		successFunc.call()
	}

	Void rollback() {
		if (ruleName != null)
			info("'$ruleName' is rolling back...'")
		rollbackFunc?.call()
	}
	
//	Str:Match matches() {
//		// flatten also removes any empty lists - cool!
//		matches := _matches?.map { (it.ruleName != null) ? it : it.matches.vals }?.flatten ?: Match#.emptyList
//		return Str:Match[:] { ordered = true }.addList(matches) |m->Str| { m.ruleName }
//	}

	Bool matched() {
		successFunc != null || (results?.any { it.matched } ?: false)
	}

	Str matchedStr() {
		(matchStr ?: Str.defVal) + (results?.join(Str.defVal) { it.matchedStr } ?: Str.defVal)
	}
	
	private Str formatLog(LogRec log) {
		log.msg
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matchedStr}"
	}
}

