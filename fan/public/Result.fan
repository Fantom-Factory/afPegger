
class Result {
	Rule 		rule	
	Duration	startTime

	
	Str? 		matchStr
	Bool?		passed
	|Result|[]?	actions		:= [,]
	Result[]?	resultList	:= [,]

	
	
	internal new make(Rule rule) {
		this.rule		= rule
		this.startTime	= Duration.now
	}	
	
	internal Void addResult(Result result) {
		// don't create lists unless we have to
		// this reduced the FantomFactory parse from 3300ms to 2800ms!
		// that's 1/2 a sec!
		if (resultList == null)
			resultList = Result[,]
		resultList.add(result)
	}
	
	internal Void success() {
//		actions?.each { it.call(this) }
		
		resultList?.each { it.success }
		rule.action?.call(matched)
	}

	internal Void rollback(PegCtx ctx) {
		ctx.unread(matched)
		
		// Ensure we only rollback the once
		// Predicates rollback if successful, so they would rollback twice if their enclosing rule failed.
		resultList		= null
		matchStr		= null
		actions			= [,]
	}

	internal Void rollup() {
//		matchStr = matched
//		
//		resultList?.each { 
//			this.actions.addAll(it.actions)
//		}
//		if (rule.action != null) {
//			actions.add(rule.action)
//		}
//		resultList = null

//		actions = resultList?.map { it.actions }?.exclude { it == null }?. flatten
//		if (rule.action != null) {
//			if (actions == null)
//				actions = [rule.action]
//			else
//				actions.add(rule.action)
//		}
//		resultList = null
	}
	
	Str matched() {
		// this 'once' (after the logger.isDebug in PegCtx) saves us some 150ms on a FantomFactory parse
		// perhaps we should manually lock it after pass() or fail has been called? 
		(matchStr ?: Str.defVal) + (resultList?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

