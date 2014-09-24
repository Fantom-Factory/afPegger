
mixin Rules {
	
	static Rule str(Str string, Bool ignoreCase := true) {
		StrRule(string.toCode, string.size) |Str? peek->Bool| { ignoreCase ? string.equalsIgnoreCase(peek ?: Str.defVal) : string.equals(peek) }
	}
	
	static Rule strNot(Str string, Bool ignoreCase := true) {
		StrNotRule(string, ignoreCase)
	}
	
//	TODO: glob Rule
//	static Rule glob(Str regex) {
//		RuleTodo()
//	}
//
//	TODO: regex Rule
//	static Rule regex(Str regex) {
//		RuleTodo()
//	}
	
	static Rule anyChar() {
		StrRule(".") |Int peek->Bool| { true }
	}

	static Rule anyCharOf(Int[] chars) {
		StrRule("[${Str.fromChars(chars).toCode(null)}]") |Int peek->Bool| { chars.contains(peek) }
	}
	
	static Rule anyCharNotOf(Int[] chars) {
		StrRule("![${Str.fromChars(chars).toCode(null)}] .") |Int peek->Bool| { !chars.contains(peek) }
	}

	static Rule anyCharInRange(Range charRange) {
		StrRule("[${charRange.min.toChar.toCode(null)}-${charRange.last.toChar.toCode(null)}]") |Int peek->Bool| { charRange.contains(peek) }
	}

	static Rule anyCharNotInRange(Range charRange) {
		StrRule("![${charRange.min.toChar.toCode(null)}-${charRange.last.toChar.toCode(null)}] .") |Int peek->Bool| { !charRange.contains(peek) }
	}
	
	static Rule anyAlphaChar() {
		StrRule("[a-zA-Z]") |Int peek->Bool| { peek.isAlpha }
	}

	static Rule anyAlphaNumChar() {
		StrRule("[a-zA-Z0-9]") |Int peek->Bool| { peek.isAlphaNum }
	}

	static Rule anyNumChar() {
		StrRule("[0-9]") |Int peek->Bool| { peek.isDigit }
	}
	
	** whitespace: space \t \n \r \f
	static Rule anySpaceChar() {
		StrRule("[ ]") |Int peek->Bool| { peek.isSpace }
	}

	** whitespace: space \t \n \r \f
	static Rule anyNonSpaceChar() {
		StrRule("![ ] .") |Int peek->Bool| { !peek.isSpace }
	}

	static Rule optional(Rule rule) {
		RepetitionRule(0, 1, rule)
	}
	
	static Rule zeroOrMore(Rule rule) {
		RepetitionRule(0, null, rule)
	}
	
	static Rule oneOrMore(Rule rule) {
		RepetitionRule(1, null, rule)
	}
	
	static Rule atLeast(Int n, Rule rule) {
		RepetitionRule(n, null, rule)
	}

	static Rule atMost(Int n, Rule rule) {
		RepetitionRule(null, n, rule)
	}

	static Rule nTimes(Range times, Rule rule) {
		RepetitionRule(times.min, times.max, rule)
	}

	static Rule sequence(Rule[] rules := [,]) {
		SequenceRule(rules)
	}
	
	static Rule firstOf(Rule[] rules := [,]) {
		FirstOfRule(rules)
	}
	
	static Rule todo(Bool pass := false) {
		TodoRule(pass)
	}

	static Rule onlyIf(Rule rule) {
		PredicateRule(rule, false)
	}
	
	static Rule onlyIfNot(Rule rule) {
		PredicateRule(rule, true)
	}
}
