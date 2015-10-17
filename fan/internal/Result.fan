
@Js
internal class Result {
	Rule 		rule	
	Str? 		matchStr
	Bool?		passed
	Result[]?	resultList
	|Obj?|[]?	actions
	
	new make(Rule rule) {
		this.rule = rule
	}	
	
	Void addResult(Result result) {
		if (resultList == null)
			resultList = Result[,]
		resultList.add(result)
	}
	
	Void success(Obj? actionCtx) {
		actions?.each { it.call(actionCtx) }
	}

	Void rollback(PegCtx ctx) {
		ctx.unreadStr(matched)
		
		// Ensure we only rollback the once
		// Predicates rollback if successful, so they would rollback twice if their enclosing rule failed.
		resultList		= null
		matchStr		= null
		actions			= null
	}

	Void rollup() {
		matched := matched

		this.actions = |Obj?|[,]
		resultList?.each {
			if (it.actions != null)
				this.actions.addAll(it.actions)
		}
		if (rule.action != null)
			actions.add(rule.action.bind([matched]))
		matchStr = matched
		resultList = null
	}
	
	Str matched() {
		return (matchStr ?: Str.defVal) + (resultList?.join(Str.defVal) { it.matchStr } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${rule.name}:${matched}"
	}
}

