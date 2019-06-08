
@Js
internal class Result {
			Rule 		rule	{ private set }
	private Result[]?	resultList
	private Int			strStart
	private Int			strEnd
	private PegMatch?	_node

	new make(Rule rule, Int strStart) {
		this.rule		= rule
		this.strStart	= strStart
	}	
	
	Void addResult(Result result) {
		if (resultList == null)
			resultList = Result[,]
		resultList.add(result)
	}
	
	Void end(PegCtx ctx) {
		strEnd = ctx.cur
	}
	
	Void rollback(PegCtx ctx) {
		ctx.rollbackTo(strStart)
	}

	Void success(Str in) {
		// I think we should call *ALL* passed rule actions, regardless of whether they consumed any chars
		resultList?.each { it.success(in) }
		rule.action?.call(matchedStr(in))
	}

	Str matchedStr(Str in) {
		in[matchedRange(in)]
	}
	
	Range matchedRange(Str in) {
		strStart..<strEnd.min(in.size)
	}
	
	Int matchedSize() {
		strEnd - strStart
	}
	
	Result? findResult(Str name) {
		resultList?.find { it.rule.name == name }
	}
	
	PegMatch match(Str in) {
		if (_node == null) _node = PegMatch(this, in)
		return _node
	}
	
	PegMatch[] matches(Str in) {
		// only bring back noteworthy nodes that actually consumed content
		resultList?.findAll { !it.matchedRange(in).isEmpty && it.rule.name != null }?.map { it.match(in) } ?: PegMatch#.emptyList
	}
	
	@NoDoc
	override Str toStr() {
		rule.name
	}
}

