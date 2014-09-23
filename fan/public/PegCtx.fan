
class PegCtx {
	private		InStream	in
	private		Result[]	resultStack	:= Result[,]
	internal	Result		rootResult
	
	internal new make(Rule rootRule, InStream in) {
		this.rootResult	= Result(rootRule.name ?: "Root Rule", rootRule.action)
		this.in			= in
	}
	
	Bool process(Rule rule) {
		result	:= resultStack.isEmpty ? rootResult : Result(rule.name, rule.action)
		resultStack.push(result)
		try {
			rule.doProcess(this)			
		} finally {
			resultStack.pop
		}
		if (result.passed && !resultStack.isEmpty)
			resultStack.peek.results.add(result)
		return result.passed
	}
	
	Void pass(Bool rulePassed) {
		resultStack.peek.passed = rulePassed
		if (!rulePassed)
			rollback
	}

	|->| rollbackFunc {
		get { resultStack.peek.rollbackFunc }
		set { resultStack.peek.rollbackFunc = it }
	}

	Str matched {
		get { resultStack.peek.matched }
		set { resultStack.peek.matchStr = it }
	}
	
	private Void rollback() {
		resultStack.peek.rollback
	}
	
	Str? read(Int n) {
		if (n == 1)
			return in.readChar?.toChar
		return Str.fromChars((0..<n).toList.map { in.readChar }.exclude { it == null })
	}

	Void unread(Str? str) {
		str?.chars?.eachr { in.unreadChar(it) }
	}
}
