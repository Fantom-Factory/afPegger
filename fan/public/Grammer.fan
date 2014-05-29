
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
		RuleTodo()
	}
	
	Rule oneOrMore(Rule rule) {
		RuleTodo()
	}
	
	Rule atLeast(Rule rule, Int times) {
		RuleTodo()
	}
	
	Rule nTimes(Rule rule, Range times) {
		RuleTodo()
	}

	Rule sequence(Rule[] rules) {
		RuleTodo()
	}
	
	Rule firstOf(Rule[] rules) {
		RuleTodo()
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
