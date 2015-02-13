
** A collection of PEG rules, ready for use!
mixin Rules {
	
	** Matches the given string. 
	** 
	** Example PEG notation:
	** 
	**   "ChuckNorris"
	static Rule str(Str string, Bool ignoreCase := true) {
		StrRule(string, ignoreCase)	// TODO: validate the str is not empty
	}
	
	** Matches one or more characters up to (but not including) the given string.  
	** 
	** Example PEG notation:
	** 
	**   (!"ChuckNorris" .)+
	static Rule strNot(Str string, Bool ignoreCase := true) {
		StrNotRule(string, ignoreCase)	// TODO: validate the str is not empty
	}
	
//	TODO: glob Rule - maybe they *only* match until the end of the line? (so we can first read until EOL) 
//	static Rule glob(Str regex) {
//		RuleTodo()
//	}
//
//	TODO: regex Rule
//	static Rule regex(Str regex) {
//		RuleTodo()
//	}
	
	** Matches the given character.  
	** 
	** Example PEG notation:
	** 
	**   "C"
	static Rule char(Int char) {
		CharRule(char.toChar.toCode) |Int peek->Bool| { char == peek }
	}

	** Matches any character.  
	** 
	** PEG notation:
	** 
	**   "."
	static Rule anyChar() {
		CharRule(".") |Int peek->Bool| { true }
	}

	** Matches any character except the given one.  
	** 
	** Example PEG notation:
	** 
	**   !"C" .
	static Rule anyCharNot(Int char) {
		CharRule("!${char.toChar.toCode} .") |Int peek->Bool| { char != peek }
	}

	** Matches any character in the given list.  
	** 
	** Example PEG notation:
	** 
	**   [ChukNoris]
	static Rule anyCharOf(Int[] chars) {
		CharRule("[${Str.fromChars(chars).toCode(null)}]") |Int peek->Bool| { chars.contains(peek) }
	}
	
	** Matches any character *not* in the given list.  
	** 
	** Example PEG notation:
	** 
	**   ![ChukNoris] .
	static Rule anyCharNotOf(Int[] chars) {
		CharRule("![${Str.fromChars(chars).toCode(null)}] .") |Int peek->Bool| { !chars.contains(peek) }
	}

	** Matches any character in the given range.  
	** 
	** Example PEG notation:
	** 
	**   [C-N]
	static Rule anyCharInRange(Range charRange) {
		CharRule("[${charRange.min.toChar.toCode(null)}-${charRange.last.toChar.toCode(null)}]") |Int peek->Bool| { charRange.contains(peek) }
	}

	** Matches any character *not* in the given range. 
	** 
	** Example PEG notation:
	** 
	**   ![C-N] .
	static Rule anyCharNotInRange(Range charRange) {
		CharRule("![${charRange.min.toChar.toCode(null)}-${charRange.last.toChar.toCode(null)}] .") |Int peek->Bool| { !charRange.contains(peek) }
	}
	
	** Matches any alphabetical character. 
	** 
	** PEG notation:
	** 
	**   [a-zA-Z]
	static Rule anyAlphaChar() {
		CharRule("[a-zA-Z]") |Int peek->Bool| { peek.isAlpha }
	}

	** Matches any alphabetical or numerical character. 
	** 
	** PEG notation:
	** 
	**   [a-zA-Z0-9]
	static Rule anyAlphaNumChar() {
		CharRule("[a-zA-Z0-9]") |Int peek->Bool| { peek.isAlphaNum }
	}

	** Matches any numerical character. 
	** 
	** PEG notation:
	** 
	**   [0-9]
	static Rule anyNumChar() {
		CharRule("[0-9]") |Int peek->Bool| { peek.isDigit }
	}

	** Matches any hexadecimal character. 
	** 
	** PEG notation:
	** 
	**   [a-fA-F0-9]
	static Rule anyHexChar() {
		CharRule("[a-fA-F0-9]") |Int peek->Bool| { peek.isDigit || ('A'..'F').contains(peek) || ('a'..'f').contains(peek) }
	}
	
	** Matches any whitespace character. 
	** 
	** PEG notation:
	** 
	**   [ \t\n\r\f]
	static Rule anySpaceChar() {
		CharRule("[ ]") |Int peek->Bool| { peek.isSpace }
	}

	** Matches any *non* whitespace character. 
	** 
	** PEG notation:
	** 
	**   ![ \t\n\r\f]
	static Rule anyNonSpaceChar() {
		CharRule("![ ] .") |Int peek->Bool| { !peek.isSpace }
	}

	** Processes the given rule and returns success whether it passes or not. 
	** 
	** Example PEG notation:
	** 
	**   (rule)?
	static Rule optional(Rule rule) {
		RepetitionRule(0, 1, rule)
	}
	
	** Processes the given rule repeatedly until it fails. 
	** 
	** Example PEG notation:
	** 
	**   (rule)*
	static Rule zeroOrMore(Rule rule) {
		RepetitionRule(0, null, rule)
	}
	
	** Processes the given rule repeatedly until it fails.
	** Returns success if it succeeded at least once.
	** 
	** Example PEG notation:
	** 
	**   (rule)+
	static Rule oneOrMore(Rule rule) {
		RepetitionRule(1, null, rule)
	}
	
	** Processes the given rule repeatedly until it fails.
	** Returns success if it succeeded at least 'n' times.
	** 
	** Example PEG notation:
	** 
	**   ???
	static Rule atLeast(Int n, Rule rule) {
		RepetitionRule(n, null, rule)
	}

	** Processes the given rule repeatedly, but at most 'n' times.
	** Returns success always.
	** 
	** Example PEG notation:
	** 
	**   ???
	static Rule atMost(Int n, Rule rule) {
		RepetitionRule(null, n, rule)
	}

	** Processes the given rule 'n' times.
	** Returns success if the it always succeeded.
	** 
	** Example PEG notation:
	** 
	**   rule rule rule ... rule
	static Rule nTimes(Int times, Rule rule) {
		RepetitionRule(times, times, rule)
	}

	** Processes the given rule at most 'n' times.
	** Returns success if it succeeded at least 'n' times.
	** 
	** Example PEG notation:
	** 
	**   ???
	static Rule between(Range times, Rule rule) {
		RepetitionRule(times.min, times.max, rule)
	}

	** Processes the given rules in order until.
	** Returns success if they all succeeded.
	** 
	** Example PEG notation:
	** 
	**   rule1 rule2 rule3 ... rule4
	** 
	** When defining a 'sequence()' rule you may also use it-block syntax:
	** 
	**   sequence { rule1, rule2, rule3, }
	static Rule sequence(Rule[] rules := [,]) {
		SequenceRule(rules)
	}
	
	** Processes the given rules in order until one succeeds.
	** Returns success any succeeded.
	** 
	** Example PEG notation:
	** 
	**   rule1 / rule2 / rule3 / ... / rule4
	** 
	** When defining a 'firstOf()' rule you may also use it-block syntax:
	** 
	**   firstOf { rule1, rule2, rule3, }
	static Rule firstOf(Rule[] rules := [,]) {
		FirstOfRule(rules)
	}
	
	** A placeholder. 
	** The rule will always succeed if 'pass' is 'true', and always fail if 'pass' is 'false'.
	static Rule todo(Bool pass := false) {
		TodoRule(pass)
	}

	** Processes the given rule and return success if it succeeded.
	** The rule is always rolled back so the characters may be subsequently re-read. 
	** 
	** Example PEG notation:
	** 
	**   &(rule)
	static Rule onlyIf(Rule rule) {
		PredicateRule(rule, false)
	}
	
	** Processes the given rule and return success if it failed.
	** The rule is always rolled back so the characters may be subsequently re-read. 
	** 
	** Example PEG notation:
	** 
	**   !(rule)
	static Rule onlyIfNot(Rule rule) {
		PredicateRule(rule, true)
	}
}
