
class Result {
	Rule 		rule	
	Str? 		matchStr
	Result[]	results		:= Result[,]
	|->|?		rollbackFunc

	Bool?		passed
	Duration	startTime
	
	
	internal new make(Rule rule) {
		this.rule		= rule
		this.startTime	= Duration.now
	}	
	
	internal Void success() {
		results.each { it.success }
		rule.action?.call(this)
	}

	internal Void rollback() {
		rollbackFunc?.call
		results.eachr { it.rollback }
	}

	Str matched() {
		(matchStr ?: Str.defVal) + (results.join(Str.defVal) { it.matched } )
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

