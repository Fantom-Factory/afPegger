
class Match {
	
	** The name of the rule that created this 'Match'.
	Str? ruleName
	
	private Str? 		_matched
	private Match[]?	_matches
	
	internal new makeFromMatched(Str? ruleName, Str matched) {
		this.ruleName	= ruleName
		this._matched	= matched
	}

	internal new makeFromMatches(Str? ruleName, Match[] matches) {
		this.ruleName	= ruleName
		this._matches	= matches
	}
	
	Match[] matches() {
		// flatten also removes any empty lists - cool!
		_matches?.map { (it.ruleName != null) ? it : it.matches }?.flatten ?: Match#.emptyList
	}

	Str matched() {
		(_matched ?: Str.defVal) + (_matches?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matched}"
	}
}
