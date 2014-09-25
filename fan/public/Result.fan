
class Result {
	Rule 		rule	
	Str? 		matchStr
	Result?		result
	Result[]?	resultList
//	|->|?		rollbackFunc
	Str?		rollbackFunc

	Bool?		passed
	Duration	startTime
	
	
	internal new make(Rule rule) {
		this.rule		= rule
		this.startTime	= Duration.now
	}	
	
	internal Void addResult(Result result) {
		// don't create lists unless we have to
		// this reduced the FantomFactory parse from 3300ms to 2800ms!
		// that's 1/2 a sec!
		if (this.result == null)
			this.result = result
		else {
			if (resultList == null)
				resultList = Result[,]
			resultList.add(result)
		}
	}
	
	internal Void success() {
		result?.success
		resultList?.each { it.success }
		rule.action?.call(this)
	}

	internal Void rollback(PegCtx ctx) {
//		ctx.unread(matched)
//		matchStr = null
	
		
//		rollbackFunc?.call
		ctx.unread(rollbackFunc)
		resultList?.eachr { it.rollback(ctx) }
		result?.rollback(ctx)
//		ctx.unread(matchStr)
		
		// Ensure we only rollback the once
		// Predicates rollback if successful, so they would rollback twice if their enclosing rule failed.
		result			= null
		resultList		= null
		rollbackFunc	= null
	}

	once Str matched() {
		// this 'once' (after the logger.isDebug in PegCtx) saves us some 150ms on a FantomFactory parse
		// perhaps we should manually lock it after pass() or fail has been called? 
		(matchStr ?: Str.defVal) + (result?.matched ?: Str.defVal) + (resultList?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

