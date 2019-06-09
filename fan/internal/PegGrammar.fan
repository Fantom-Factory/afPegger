
@Js
internal class PegGrammar : Rules {
	
	private NamedRules rules() {
		rules			:= NamedRules()
		grammar			:= rules["grammar"]
		line			:= rules["line"]
		emptyLine		:= rules["emptyLine"]
		commentLine		:= rules["commentLine"]
		ruleDef			:= rules["ruleDef"]
		ruleName		:= rules["ruleName"]
		rule			:= rules["rule"]
		_sequence		:= rules["sequence"]
		_firstOf		:= rules["firstOf"]
		expression		:= rules["expression"]
		predicate		:= rules["predicate"]
		multiplicity	:= rules["multiplicity"]
		literal			:= rules["literal"]
		chars			:= rules["chars"]
		macro			:= rules["macro"]
		dot				:= rules["dot"]
		
//		ruleDef			= ruleName WSP* ":" WSP* rule (NL / EOS)		// what of multiline?
//		ruleName		= [a-z]i [a-z0-9]i*
//
//		rule			= firstOf / sequence / FAIL
//		sequence		= expression (WSP+ expression)*
//		firstOf			= expression WSP+ "/" WSP+ expression (WSP+ "/" WSP+ expression)*
//		
//		expression		= predicate? ("(" rule ")" / ruleName / literal / chars / dot) multiplicity?
//		predicate		= "!" / "&"
//		multiplicity	= "*" / "+" / "?"
//		literal			= ("\"" (("\" [\\"fnrt]) / [^"])+ "\"") / ("'" (("\" [\\'fnrt]) / [^'])+ "'")
//		chars			= "[" "^"? (("\" [\\"fnrt]) / ([a-zA-Z0-9] "-" [a-zA-Z0-9]) / [a-zA-Z0-9])+ "]" "i"?
//		dot				= "."
		
		eos						:= eos			{ it.debug = false; it.useInResult = false }
		WSP						:= spaceChar	{ it.debug = false; it.useInResult = false }
		NL						:= newLineChar	{ it.debug = false; it.useInResult = false }
		EOL						:= eol			{ it.debug = false; it.useInResult = false }
		FAIL					:= NoOpRule("PEG parse FAIL", false)
		
		rules["grammar"]		= oneOrMore(sequence { onlyIfNot(eos), line } )
		rules["line"]			= firstOf  { emptyLine, commentLine, ruleDef, FAIL, }
		rules["emptyLine"]		= sequence { zeroOrMore(WSP), EOL, }
		rules["commentLine"]	= sequence { zeroOrMore(WSP), str("//"), zeroOrMore(WSP), zeroOrMore(newLineChar(true)).withName("comment"), EOL, }

		rules["ruleDef"]		= sequence { ruleName, zeroOrMore(WSP), char('='), zeroOrMore(WSP), rule, EOL, }
		rules["ruleName"]		= sequence { charIn('a'..'z'), zeroOrMore(alphaNumChar), }

		rules["rule"]			= firstOf  { _firstOf, _sequence, FAIL, }
		rules["sequence"]		= sequence { expression, zeroOrMore(sequence { oneOrMore(WSP), expression, }), }
		rules["firstOf"]		= sequence { expression, oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, zeroOrMore(sequence { oneOrMore(WSP), char('/'), oneOrMore(WSP), expression, }), }

		rules["expression"]		= sequence { optional(predicate), firstOf { sequence { char('('), rule, char(')'), }, ruleName, literal, chars, macro, dot, FAIL, }.withName("type"), optional(multiplicity), }
		rules["predicate"]		= firstOf  { char('!'), char('&'), }
		rules["multiplicity"]	= firstOf  { char('*'), char('+'), char('?'), }
		rules["literal"]		= sequence { char('"'), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot('"'), }), char('"'), optional(char('i')), }
		rules["chars"]			= sequence { char('['), oneOrMore(firstOf { sequence { char('\\'), anyChar, }, charNot(']'), }), char(']'), optional(char('i')), }
		rules["macro"]			= sequence { char('\\'), oneOrMore(alphaChar), }
		rules["dot"]			= char('.')
		
		// built in rules
		
		echo(rules.validate.definition)
		return rules.validate
	}
	
	private NamedRules toRuleDefs(PegMatch? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		if (match.name != "grammar")
			throw UnsupportedErr("Unknown rule: ${match.name}")
		
		match.dump
		
		rules := NamedRules()
		lines := match.matches
		lines.each |line| {
			if (line.match.name == "ruleDef") {
				def  := line.match
				name := def["ruleName"].matched
				rule := toRule(def["rule"], rules)
				rule.name = name
				rules[name] = rule
			}
		}
		return rules.validate
	}

	private Rule toRule(PegMatch? match, NamedRules? allRules) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		if (match.name != "rule")
			throw UnsupportedErr("Unknown rule: ${match.name}")

		rule := fromRule(match.match, allRules)
		return rule
	}

	private Rule fromRule(PegMatch match, NamedRules? allRules) {
		rule := null as Rule
		switch (match.name) {
			case "sequence":
				if (match.matches.size == 1)
					rule = fromExpression(match.match, allRules)
				else {
					rules := match.matches.map { fromExpression(it, allRules) }
					rule = Rules.sequence(rules)
				}

			case "firstOf":
				rules := match.matches.map { fromExpression(it, allRules) }
				rule = Rules.firstOf(rules)
			
			default:
				throw UnsupportedErr("Unknown rule: ${match.name}")
		}
		return rule
	}
	
	private Rule fromExpression(PegMatch match, NamedRules? allRules) {
		if (match.name != "expression")
			throw ArgErr("Match should be 'expression', not '${match.name}'")

		exType	:= match["type"] as PegMatch
		multi	:= match["multiplicity"]?.matched
		pred	:= match["predicate"]?.matched
		exName	:= exType.match.name
		exRule	:= null as Rule

		switch (exName) {
			case "rule"		: exRule = fromRule(exType.match.match, allRules)
			case "ruleName"	: exRule = fromRuleName(match.matched, allRules)
			case "literal"	: exRule = StrRule.fromStr(match.matched)
			case "chars"	: exRule = CharRule.fromStr(match.matched)
			case "macro"	: exRule = fromMacro(match.matched)
			case "dot"		: exRule = Rules.anyChar
			default			: throw UnsupportedErr("Unknown expression: ${exName}")
		}
		
		if (multi != null)
			switch (multi) {
				case "?"	: exRule = Rules.optional(exRule)
				case "+"	: exRule = Rules.oneOrMore(exRule)
				case "*"	: exRule = Rules.zeroOrMore(exRule)
				default		: throw UnsupportedErr("Unknown multiplicity: ${multi}")
			}
		
		if (pred != null)
			switch (pred) {
				case "&"	: exRule = Rules.onlyIf(exRule)
				case "!"	: exRule = Rules.onlyIfNot(exRule)
				default		: throw UnsupportedErr("Unknown predicate: ${pred}")
			}
		
		return exRule
	}
	
	private Rule fromRuleName(Str ruleName, NamedRules? rules) {
		if (rules == null)
			throw ParseErr("Patterns may not contain named rules")
		return rules[ruleName]
	}
	
	private Rule fromMacro(Str macro) {
		switch (macro[1..-1]) {
			case "n"		: return Rules.newLineChar
			case "space"	: return Rules.spaceChar
			case "white"	: 
			case "s"		: return Rules.whitespaceChar
			case "S"		: return Rules.whitespaceChar(true)
			case "digit"	: 
			case "d"		: return Rules.numChar
			case "D"		: return Rules.numChar(true)
			case "letter"	: 
			case "a"		: return Rules.alphaChar
			case "A"		: return Rules.alphaChar(true)
			case "w"		: return Rules.wordChar
			case "W"		: return Rules.wordChar(true)
			case "upper"	: return Rules.charIn('A'..'Z')
			case "lower"	: return Rules.charIn('a'..'z')
			case "ident"	: return Rules.sequence { Rules.charRule("[a-zA-Z_]"), Rules.zeroOrMore(Rules.wordChar), }
			case "eol"		: return Rules.eol
			case "eos"		: return Rules.eos
		}
		throw UnsupportedErr("Unknown macro: $macro")
	}
	
	Rule parseRule(Str pattern) {
		toRule(Peg(pattern, rules["rule"]).match, null)
	}
	
	Rule parseGrammar(Str grammar, Str? rootRuleName) {
		ruleDefs := toRuleDefs(Peg(grammar, rules["grammar"]).match)
		
		echo(ruleDefs.definition)
		
		throw Err("fail")
	}
}
