
class Result {
//	private Log log	:= Result#.pod.log
	
	** The name of the rule that created this 'Result'.
	Str? 		ruleName
	|Result|?	ruleAction
	
	Str? 		matchStr
	Result[]	results		:= Result[,]
	|->|?		rollbackFunc
//	LogRec[]?	logs		:= LogRec[,]

	Bool?		passed
	Duration	startTime
	
	
	internal new make(Str? ruleName, |Result|? ruleAction) {
		this.ruleName	= ruleName
		this.ruleAction	= ruleAction
		this.startTime	= Duration.now
	}

//	Void ruleFailed(Str desc) {
//		bp = false
//		if (ruleName == null)
//			debug(" - failed - $desc")
//		else
//			debug("'$ruleName' failed - $desc")		
//	}
//
//	Void rulePassed(Str desc) {
//		bp = true
//		msg := matchStr ?: desc
//		if (ruleName == null)
//			debug(" - matched $desc")
//		else
//			info("'$ruleName' matched $desc")
//	}
//	
//	Void debug(Str msg) {
//		logs.add(LogRec(DateTime.now, LogLevel.debug, ruleName ?: Str.defVal, msg))
//		log.info(msg.toCode(null))
//	}
//
//	Void info(Str msg) {
//		logs.add(LogRec(DateTime.now, LogLevel.info, ruleName, msg))
//		log.warn(msg.toCode(null))
//	}
//
//	Str[] msgs() {
//		(results?.map { it.msgs } ?: [,]).addAll(logs.findAll { it.level >= LogLevel.info }.map { formatLog(it) }).flatten
//	}
//
//	Str[] allMsgs() {
//		(results?.map { it.allMsgs } ?: [,]).addAll(logs.map { formatLog(it) }).flatten
//	}
	
	
	Void success() {
//		if (ruleName != null)
//			info("'$ruleName' is successful!'")
		results.each { it.success }
		ruleAction?.call(this)
	}

	internal Void rollback() {
//		if (ruleName != null)
//			info("'$ruleName' is rolling back...'")
		rollbackFunc?.call
		results.eachr { it.rollback }
	}
	
//	Str:Match matches() {
//		// flatten also removes any empty lists - cool!
//		matches := _matches?.map { (it.ruleName != null) ? it : it.matches.vals }?.flatten ?: Match#.emptyList
//		return Str:Match[:] { ordered = true }.addList(matches) |m->Str| { m.ruleName }
//	}

	Str matched() {
		(matchStr ?: Str.defVal) + (results.join(Str.defVal) { it.matched } )
	}
	
	private Str formatLog(LogRec log) {
		log.msg
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matched}"
	}
}

