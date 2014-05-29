
mixin Grammer {
	
	// TODO: ignore case
	Rule str(Str string) {
		StrRule(string)
	}
	
	Rule anyChar() {
		RuleTodo()
	}

	Rule anyOf(Int[] chars) {
		RuleTodo()
	}
	
	Rule noneOf(Int[] chars) {
		RuleTodo()
	}

	Rule inRange(Range charRange) {
		InRangeRule(charRange)
	}
	
//	Rule glob(Str regex) {
//		RuleTodo()
//	}
//
//	Rule regex(Str regex) {
//		RuleTodo()
//	}

	Rule optional(Rule rule) {
		RuleTodo()
	}
	
	Rule zeroOrMore(Rule rule) {
		AtLeastRule(0, rule)
	}
	
	Rule oneOrMore(Rule rule) {
		AtLeastRule(1, rule)
	}
	
	Rule atLeast(Int times, Rule rule) {
		AtLeastRule(times, rule)
	}

	Rule nTimes(Range times, Rule rule) {
		RuleTodo()
	}

	Rule sequence(Rule[] rules) {
		SequenceRule(rules)
	}
	
	Rule firstOf(Rule[] rules) {
		FirstOfRule(rules)
	}
	
	Rule testIf(Rule[] rules) {
		RuleTodo()
	}
	
	Rule testIfNot(Rule[] rules) {
		RuleTodo()
	}

	Rule custom(|->Bool| customRule) {
		RuleTodo()
	}

	Rule action(|->| action) {
		RuleTodo()
	}

	
}
