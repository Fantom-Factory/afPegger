
** (Advanced) 
** A collection of utility methods that return PEG rules.
** 
** Use when programmatically creating PEG grammar.
@Js
mixin Rules {
	
	// ---- Str rules -----------------------------------------------------------------------------
	
	** Matches the given string. 
	** 
	** Example PEG notation:
	** 
	**   "ChuckNorris"
	static Rule str(Str string, Bool ignoreCase := false) {
		StrRule(string, ignoreCase)
	}

	** Matches one or more characters up to (but not including) the given string.  
	** 
	** Example PEG notation:
	** 
	**   (!"ChuckNorris" .)+
	static Rule strNot(Str string, Bool ignoreCase := false) {
		StrNotRule(string, ignoreCase)
	}

	// ---- Char rules ----------------------------------------------------------------------------

	** Matches any character.  
	** 
	** PEG notation:
	** 
	**   .
	static Rule anyChar() {
		AnyCharRule()
	}

	** Multi-purpose char class rule.  
	** 
	** Example PEG notation:
	** 
	**   [a-z_]i
	static Rule charRule(Str charClass) {
		CharRule.fromStr(charClass)
	}

	** Matches the given character.  
	** 
	** Example PEG notation:
	** 
	**   [C]
	static Rule char(Int char, Bool not := false) {
		not ? CharRule(char.toChar.toCode(null).replace("]", "\\]").replace("-", "\\-"), not) |Int peek->Bool| { char == peek }
			: StrMimickCharRule(char, false)	// this looks better than char rule & parses faster than a str rule 
	}

	** Matches any character except the given one.  
	** 
	** Example PEG notation:
	** 
	**   [^C]
	static Rule charNot(Int ch) {
		char(ch, true)
	}

	** Matches any character in the given list.  
	** 
	** Example PEG notation:
	** 
	**   [ChukNoris]
	static Rule charOf(Int[] chars, Bool not := false) {
		if (chars.isEmpty) throw ArgErr("Chars may not be empty")
		return CharRule(Str.fromChars(chars).toCode(null), not) |Int peek->Bool| { chars.contains(peek) }
	}
	
	** Matches any character *not* in the given list.  
	** 
	** Example PEG notation:
	** 
	**   [^ChukNoris]
	static Rule charNotOf(Int[] chars) {
		charOf(chars, true)
	}

	** Matches any character in the given range.  
	** 
	** Example PEG notation:
	** 
	**   [C-N]
	static Rule charIn(Range charRange, Bool not := false) {
		CharRule(charRange.min.toChar + "-" + charRange.last.toChar, not) |Int peek->Bool| { charRange.contains(peek) }
	}
	
	** Matches any alphabetical ASCII character. 
	** 
	** PEG notation:
	** 
	**   [a-zA-Z]
	static Rule alphaChar(Bool not := false) {
		CharRule("a-zA-Z", not) |Int peek->Bool| { peek.isAlpha }
	}

	** Matches any alphabetical ASCII or numerical character. 
	** 
	** PEG notation:
	** 
	**   [a-zA-Z0-9]
	static Rule alphaNumChar(Bool not := false) {
		CharRule("a-zA-Z0-9", not) |Int peek->Bool| { peek.isAlphaNum }
	}

	** Matches any numerical character. 
	** 
	** PEG notation:
	** 
	**   [0-9]
	static Rule numChar(Bool not := false) {
		CharRule("0-9", not) |Int peek->Bool| { peek.isDigit }
	}

	** Matches any hexadecimal character. 
	** 
	** PEG notation:
	** 
	**   [a-fA-F0-9]
	static Rule hexChar(Bool not := false) {
		CharRule("0-9A-F", not) |Int peek->Bool| { peek.isDigit || ('A'..'F').contains(peek) || ('a'..'f').contains(peek) } { it.ignoresCase = true }
	}
	
	** Matches any whitespace character, including new lines.
	** 
	** PEG notation:
	** 
	**   [ \t\n]
	static Rule whitespaceChar(Bool not := false) {
		CharRule(" \t\n".toCode(null), not) |Int peek->Bool| { peek.isSpace }
	}
	
	** Matches any space character (excluding new line chars). 
	** 
	** PEG notation:
	** 
	**   [ \t]
	static Rule spaceChar(Bool not := false) {
		CharRule(" \t".toCode(null), not) |Int peek->Bool| { peek == ' ' || peek == '\t' }
	}
	
	** Matches any word character, used as a Fantom identifier. 
	** 
	** PEG notation:
	** 
	**   [a-zA-Z0-9_]
	static Rule wordChar(Bool not := false) {
		CharRule("a-zA-Z0-9_".toCode(null), not) |Int peek->Bool| { peek.isAlphaNum || peek == '_' }
	}

	** Matches the new line character.
	** This assumes all new lines have been normalised to '\n'. 
	** 
	** PEG notation:
	** 
	**   [\n]
	static Rule newLineChar(Bool not := false) {
		char('\n', not)
	}

	// ---- Repetition rules ----------------------------------------------------------------------

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
	**   rule{3,}
	static Rule atLeast(Int n, Rule rule) {
		RepetitionRule(n, null, rule)
	}

	** Processes the given rule repeatedly, but at most 'n' times.
	** Returns success always.
	** 
	** Example PEG notation:
	** 
	**   rule{,5}
	static Rule atMost(Int n, Rule rule) {
		RepetitionRule(null, n, rule)
	}

	** Processes the given rule 'n' times.
	** Returns success if the it always succeeded.
	** 
	** Example PEG notation:
	** 
	**   rule{5,5}
	static Rule nTimes(Int times, Rule rule) {
		RepetitionRule(times, times, rule)
	}

	** Processes the given rule between the given values (inclusive).
	** If 'min' is 'null' it is taken to be 0.
	** If 'max' is 'null' it is taken to be infinity.
	** 
	** Example PEG notation:
	** 
	**  rule{2,6} 
	static Rule between(Int? min, Int? max, Rule rule) {
		RepetitionRule(min, max, rule)
	}

	// ---- Expression rules ----------------------------------------------------------------------
	
	** Processes the given rules in order until.
	** Returns success if they all succeeded.
	** 
	**   sequence([rule1, rule2, rule3])
	** 
	** Example PEG notation:
	** 
	**   rule1 rule2 rule3 ... rule4
	** 
	** When defining a 'sequence()' rule you may also use it-block syntax:
	** 
	**   sequence { rule1, rule2, rule3, }
	static Rule sequence(Rule[] rules := Rule[,]) {
		SequenceRule(rules)
	}
	
	** Processes the given rules in order until one succeeds.
	** Returns success any succeeded.
	** 
	**   firstOf([rule1, rule2, rule3])
	** 
	** Example PEG notation:
	** 
	**   rule1 / rule2 / rule3 / ... / rule4
	** 
	** When defining a 'firstOf()' rule you may also use it-block syntax:
	** 
	**   firstOf { rule1, rule2, rule3, }
	static Rule firstOf(Rule[] rules := Rule[,]) {
		FirstOfRule(rules)
	}

	// ---- Predicate rules -----------------------------------------------------------------------
	
	
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

	// ---- Macro rules ---------------------------------------------------------------------------

	** Matches if at the Start-Of-Stream (SOS).
	** (Does not consume an characters.)
	**  
	** Example PEG notation:
	** 
	**   \sos
	static Rule sos() {
		SosRule()
	}

	** Matches if at the End-Of-Stream (EOS).
	** (Does not consume an characters.)
	**  
	** Example PEG notation:
	** 
	**   \eos
	static Rule eos() {
		EosRule()
	}

	** Matches if at the Start-Of-Line (SOL) (or at the start of stream).
	**  
	** Example PEG notation:
	** 
	**   \sos
	static Rule sol() {
		SolRule()
	}

	** Matches if at the End-Of-Line (EOL) (or at the end of stream).
	**  
	** Example PEG notation:
	** 
	**   \eol
	static Rule eol() {
		EolRule()
	}

	** Matches an uppercase character in the current locale.
	** See `sys::Locale` for details.
	**  
	** Example PEG notation:
	** 
	**   \upper
	static Rule upper() {
		UpperRule()
	}
	
	** Matches a lowercase character in the current locale.
	** See `sys::Locale` for details.
	**  
	** Example PEG notation:
	** 
	**   \lower
	static Rule lower() {
		LowerRule()
	}
	
	** Matches any character in the current locale.
	** See `sys::Locale` for details.
	**  
	** Example PEG notation:
	** 
	**   \aplha
	static Rule alpha() {
		AlphaRule()
	}
	
	** A rule that will *always* pass.
	** Does not consume any characters.
	**  
	** Example PEG notation:
	** 
	**   \pass
	static Rule pass() {
		PassRule()
	}
	
	** A rule that will *always* fail.
	** Does not consume any characters.
	**  
	** Example PEG notation:
	** 
	**   \fail
	static Rule fail() {
		FailRule()
	}
	
	
	
//	** No operation - a placeholder. 
//	** This rule consumes no input and will always succeed if 'pass' is 'true', and always fail if 'pass' is 'false'.
//	** 
//	** Example PEG notation:
//	** 
//	**   \noop(true)
//	static Rule noop(Bool pass := true) {
//		NoOpRule(pass)
//	}
	
//	** Dump the message and parsing stacktrace to std-out. 
//	** Use to aid the debugging of PEG grammar.
//	** 
//	** Example PEG notation:
//	** 
//	**   \dump(TODO)
//	static Rule dump(Str? msg := null) {
//		DumpRule(msg)
//	}

//	** Logs a message to PEG degbug. 
//	** Use to place marker text in the reams of PEG debug output..
//	** 
//	** Example PEG notation:
//	** 
//	**   \log(TODO)
//	static Rule log(Str? msg := null) {
//		LogRule(msg)
//	}

	** This rule throws an error if processed. 
	** 
	** Example PEG notation:
	** 
	**   \fail(FAIL)
	static Rule err(Str msg := "FAIL") {
		ErrRule(msg)
	}
}
