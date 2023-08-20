
@Js
internal class Result {
			Rule 		rule	{ private set }
			Result?		parent
	private Result[]?	resultList
	private Int			strStart
	private Int			strEnd
	private Match?		_match
	private Match[]?	_matches

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
		ctx.rollbackToPos(strStart)
	}

	Str matchedStr(Str in) {
		in[matchedRange(in)]
	}
	
	Range matchedRange(Str in) {
		strStart.min(in.size)..<strEnd.min(in.size)
	}
	
	Int matchedSize() {
		strEnd - strStart
	}
	
	Match? findMatch(Str name, Str in) {
		// todo should be finding rule labels AND names?
		matches(in).find |match| {
			// exclude names (in special cases)
			matchRuleName := match.rule is RuleRef && match.rule->realRule->useInResult == false ? null : match.rule.name
			return match.rule.label == name || matchRuleName == name
		}
	}
	
	Match match(Result? parent, Str in) {
		if (_match == null) _match = Match(this, in) { this.parent = parent }
		return _match
	}
	
	Match[] matches(Str in) {
		if (_matches == null)
			// only bring back noteworthy nodes that actually consumed content
			_matches = resultList?.findAll { !it.matchedRange(in).isEmpty && it.hasNamedRules }?.map { it.findNamedMatches(this, in) }?.flatten ?: Match#.emptyList
		return _matches
	}
	
	private Bool hasNamedRules() {
		((rule.name != null || rule.label != null) && rule.useInResult)|| (resultList != null && resultList.any { it.hasNamedRules })
	}
	
	private Obj findNamedMatches(Result? parent, Str in) {
		if ((rule.name != null || rule.label != null) && rule.useInResult)
			return match(parent, in)
		if (resultList == null)
			return Match#.emptyList
		return resultList.map { it.findNamedMatches(parent, in) }
	}
	
	@NoDoc
	override Str toStr() {
		[rule.label, rule.name].exclude { it == null }.join(":").trimToNull ?: "???:???"
	}
}

