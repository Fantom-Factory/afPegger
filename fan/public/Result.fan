
class Result {
	Rule 		rule	
	Str? 		matchStr
	Result[]?	results		:= Result[,]
	|->|?		rollbackFunc

	Bool?		passed
	Duration	startTime
	
	
	internal new make(Rule rule) {
		this.rule		= rule
		this.startTime	= Duration.now
	}	
	
	internal Void success() {
		results?.each { it.success }
		rule.action?.call(this)
	}

	internal Void rollback() {
		rollbackFunc?.call
		results?.eachr { it.rollback }
		
		// Ensure we only rollback the once
		// Predicates rollback if successful, so they would rollback twice if their enclosing rule failed.
		results			= null
		rollbackFunc	= null
	}

	Str matched() {
		(matchStr ?: Str.defVal) + (results?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

