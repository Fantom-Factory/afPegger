
internal class Result {
	
	** The name of the rule that created this 'Result'.
	Str? ruleName
	
	private Str? 		matchStr
	private Result[]?	results
	private |->|?		rollback
	private |->|?		success
	
	new make(Str? ruleName) {
		this.ruleName = ruleName		
	}

	Bool passed() {
		success != null || results?.any { it.passed }
	}
	
//	Str:Match matches() {
//		// flatten also removes any empty lists - cool!
//		matches := _matches?.map { (it.ruleName != null) ? it : it.matches.vals }?.flatten ?: Match#.emptyList
//		return Str:Match[:] { ordered = true }.addList(matches) |m->Str| { m.ruleName }
//	}

	Str matched() {
		(matchStr ?: Str.defVal) + (results?.join(Str.defVal) { it.matched } ?: Str.defVal)
	}
	
	@NoDoc
	override Str toStr() {
		"${ruleName}:${matched}"
//		"${ruleName}:${matched} ${matches} ::: ${_matched} ${_matches}"
	}
	
}
