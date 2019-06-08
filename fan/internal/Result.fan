
@Js
internal class Result {
			Rule 		rule	{ private set }
	private Result[]?	resultList
	private Int			strStart
	private Int			strEnd
	private PegMatch?	_match
	private PegMatch[]?	_matches

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
		if (_match == null) _match = PegMatch(this, in)
		return _match
	}
	
	PegMatch[] matches(Str in) {
		if (_matches == null)
			// only bring back noteworthy nodes that actually consumed content
			_matches = resultList?.findAll { !it.matchedRange(in).isEmpty && it.hasNamedRules }?.map { it.findNamedMatches(in) }?.flatten ?: PegMatch#.emptyList
		return _matches
	}
	
	private Bool hasNamedRules() {
		(rule.name != null && rule.useInResult)|| (resultList != null && resultList.any { it.hasNamedRules })
	}
	
	private Obj findNamedMatches(Str in) {
		if (rule.name != null && rule.useInResult)
			return match(in)
		if (resultList == null)
			return PegMatch#.emptyList
		return resultList.map { it.findNamedMatches(in) }
	}
	
	@NoDoc
	override Str toStr() {
		rule.name
	}
}

