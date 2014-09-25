
internal class Result {
	Rule 		rule	
	Duration	startTime

	Str? 		matchStr
	Bool?		passed
	Result[]?	resultList
	|->|[]?		actions

	
	
	new make(Rule rule) {
		this.rule		= rule
		this.startTime	= Duration.now
	}	
	
	Void addResult(Result result) {
		// don't create lists unless we have to
		// this reduced the FantomFactory parse from 3300ms to 2800ms!
		// that's 1/2 a sec!
		if (resultList == null)
			resultList = Result[,]
		resultList.add(result)
	}
	
	Void success() {
		actions?.each { it.call }
	}

	Void rollback(PegCtx ctx) {
		ctx.unread(matched)
		
		// Ensure we only rollback the once
		// Predicates rollback if successful, so they would rollback twice if their enclosing rule failed.
		resultList		= null
		matchStr		= null
		actions			= null
	}

	Void rollup() {
		resultList?.each {
			if (it.actions != null) {
				if (this.actions == null)
					this.actions = |->|[,]
				this.actions.addAll(it.actions)
			}
		}
		if (rule.action != null) {
			if (this.actions == null)
				this.actions = |->|[,]
			actions.add(rule.action.bind([matched]))
		}
		matchStr = matched
		resultList = null
	}
	
	Str matched() {
		// this 'once' (after the logger.isDebug in PegCtx) saves us some 150ms on a FantomFactory parse
		// perhaps we should manually lock it after pass() or fail has been called? 
		(matchStr ?: Str.defVal) + (resultList?.join(Str.defVal) { it.matchStr } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

