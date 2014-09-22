
class Result {
	
	** The name of the rule that created this 'Result'.
	Str? 		ruleName
	
	Str? 		matchStr
	Result[]?	results
	|->|?		rollbackFunc
	|->|?		successFunc
	LogRec[]?	logs		:= LogRec[,]

	
	new make(Str? ruleName) {
		this.ruleName = ruleName		
	}

	Void debug(Str msg) {
		logs.add(LogRec(DateTime.now, LogLevel.debug, ruleName, msg))
	}

	Void info(Str msg) {
		logs.add(LogRec(DateTime.now, LogLevel.info, ruleName, msg))
	}

	Str[] msgs() {
		(results?.map { it.msgs } ?: [,]).addAll(logs.findAll { it.level >= LogLevel.info }.map { formatLog(it) }).flatten
	}

	Str[] allMsgs() {
		(results?.map { it.allMsgs } ?: [,]).addAll(logs.map { formatLog(it) }).flatten
	}
	
	Bool passed() {
		successFunc != null || (results?.any { it.passed } ?: false)
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

	Str matched() {
		(matchStr ?: Str.defVal) + (results?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	private Str formatLog(LogRec log) {
		log.msg
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matched}"
	}
}

