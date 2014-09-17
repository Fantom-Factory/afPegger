
mixin Rules {
	
	// TODO: ignore case
	static Rule str(Str string) {
		StrRule(string)
	}
	
	static Rule anyChar() {
		CharRule("'.'") |Int peek->Bool| { true }
	}

	static Rule anyCharOf(Int[] chars) {
		CharRule("[${Str.fromChars(chars)}]") |Int peek->Bool| { chars.contains(peek) }
	}
	
	static Rule anyCharNotOf(Int[] chars) {
		CharRule("![${Str.fromChars(chars)}]") |Int peek->Bool| { !chars.contains(peek) }
	}

	static Rule anyCharInRange(Range charRange) {
		CharRule("[${charRange.min.toChar}-${charRange.last.toChar}]") |Int peek->Bool| { charRange.contains(peek) }
	}
	
	static Rule anyAlphaChar() {
		CharRule("[a-zA-Z]") |Int peek->Bool| { peek.isAlpha }
	}

	static Rule anyAlphaNumChar() {
		CharRule("[a-zA-Z0-9]") |Int peek->Bool| { peek.isAlphaNum }
	}

	static Rule anyNumChar() {
		CharRule("[0-9]") |Int peek->Bool| { peek.isDigit }
	}
	
	** whitespace: space \t \n \r \f
	static Rule anySpaceChar() {
		CharRule("[ ]") |Int peek->Bool| { peek.isSpace }
	}

	** whitespace: space \t \n \r \f
	static Rule anyNonSpaceChar() {
		CharRule("![ ]") |Int peek->Bool| { !peek.isSpace }
	}
	
//	static Rule glob(Str regex) {
//		RuleTodo()
//	}
//
//	static Rule regex(Str regex) {
//		RuleTodo()
//	}

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

	static Rule sequence(Rule[] rules) {
		SequenceRule(rules)
	}
	
	static Rule firstOf(Rule[] rules) {
		FirstOfRule(rules)
	}
	
	static Rule proxy(|Obj?->Rule| ruleFunc) {
		ProxyRule(ruleFunc)
	}
	
	static Rule onlyIf(Rule[] rules) {
		RuleTodo()
	}
	
	static Rule onlyIfNot(Rule[] rules) {
		RuleTodo()
	}

	static Rule custom(|->Bool| customRule) {
		RuleTodo()
	}

	static Rule action(|->| action) {
		RuleTodo()
	}
	
	static Rule todo() {
		RuleTodo()
	}
}
