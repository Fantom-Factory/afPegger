
mixin Rules {
	
	// TODO: ignore case
	static Rule str(Str string) {
		StrRule(string)
	}
	
	static Rule anyChar() {
		RuleTodo()
	}

	static Rule anyOf(Int[] chars) {
		RuleTodo()
	}
	
	static Rule noneOf(Int[] chars) {
		RuleTodo()
	}

	static Rule inRange(Range charRange) {
		InRangeRule(charRange)
	}
	
//	static Rule glob(Str regex) {
//		RuleTodo()
//	}
//
//	static Rule regex(Str regex) {
//		RuleTodo()
//	}

	static Rule optional(Rule rule) {
		RuleTodo()
	}
	
	static Rule zeroOrMore(Rule rule) {
		AtLeastRule(0, rule)
	}
	
	static Rule oneOrMore(Rule rule) {
		AtLeastRule(1, rule)
	}
	
	static Rule atLeast(Int times, Rule rule) {
		AtLeastRule(times, rule)
	}

	static Rule nTimes(Range times, Rule rule) {
		RuleTodo()
	}

	static Rule sequence(Rule[] rules) {
		SequenceRule(rules)
	}
	
	static Rule firstOf(Rule[] rules) {
		FirstOfRule(rules)
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
	
}
