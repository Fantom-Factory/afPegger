
class Match {
	
	Str? ruleName
	
	private Str? 		matched
	private Match[]?	matches
	
	new makeFromMatched(Str? ruleName, Str matched) {
		this.ruleName	= ruleName
		this.matched	= matched
	}

	new makeFromMatches(Str? ruleName, Match[] matches) {
		this.ruleName	= ruleName
		this.matches	= matches
	}
	
	override Str toStr() {
		str := (ruleName == null) ? Str.defVal : ruleName + ":"
		str += (matched  == null) ? Str.defVal : matched
		str += (matches  == null) ? Str.defVal : matches.toStr
		return str
	}
}
