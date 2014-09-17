
class Result {
	
	** The name of the rule that created this 'Result'.
	Str? ruleName
	
	private Str? 		_matched
	private Result[]?	_results
	private |->|?		_rollbackFunc
	private |->|?		_successFunc
	
	internal new makeFromMatched(Str? ruleName, Str matched) {
		this.ruleName	= ruleName
		this._matched	= matched
	}

	internal new makeFromMatches(Str? ruleName, Match[] matches) {
		this.ruleName	= ruleName
		this._matches	= matches
	}
	
	Str:Match matches() {
		// flatten also removes any empty lists - cool!
		matches := _matches?.map { (it.ruleName != null) ? it : it.matches.vals }?.flatten ?: Match#.emptyList
		return Str:Match[:] { ordered = true }.addList(matches) |m->Str| { m.ruleName }
	}

	Str matched() {
		(_matched ?: Str.defVal) + (_matches?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matched}"
//		"${ruleName}:${matched} ${matches} ::: ${_matched} ${_matches}"
	}
	
}
