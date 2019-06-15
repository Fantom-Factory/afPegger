
@Js
internal class BnfGrammar : Rules {

	static Grammar bnfGrammar() {
		// todo - cache this grammer, mainly for testing
		grammar := `fan://afPegger/res/bnf.peg.txt`.toFile.readAllStr
		_grammar := Peg.parseGrammar(grammar)
		return _grammar
	}
	
	Grammar parseGrammar(Str grammar) {
		peg := Peg(grammar, bnfGrammar["grammar"])
		return toGrammar(peg.match)
	}

	Rule parseRule(Str pattern) {
		peg := Peg(pattern, bnfGrammar["elements"])
		throw UnsupportedErr()
//		return toRule(peg.match, null)
	}
	
	// ---- Helper methods ----
	
	internal Grammar toGrammar(Match? match) {
		if (match == null)
			throw ParseErr("Could not match PEG")
		assertName(match, "grammar")
		
		newGrammar := Grammar()
		match.matches.each |ruleDef| {
			assertName(ruleDef, "rule")
				
			name := ruleDef["rulename"].matched
			if (fromCoreRule(name, false) != null)
				throw ParseErr("Core rules may not be overridden: $name")

			rule := fromAlternation(ruleDef["alternation"], newGrammar)
			rule.name = name
			newGrammar[name] = rule
		}
		return newGrammar.validate
	}

	private Rule fromAlternation(Match match, Grammar? newGrammar) {
		assertName(match, "alternation")
		rules := match.matches.map { fromConcatenation(it, newGrammar) }
		rule  := rules.size == 1 ? rules.first : Rules.firstOf(rules)
		return rule 
	}
	
	private Rule fromConcatenation(Match match, Grammar? newGrammar) {
		assertName(match, "concatenation")
		rules := match.matches.map { fromRepetition(it, newGrammar) }
		rule  := rules.size == 1 ? rules.first : Rules.sequence(rules)
		return rule
	}
	
	private Rule fromExpression(Match match, Grammar? newGrammar) {
		rule	:= null as Rule

		switch (match.name) {
			case "binVal"		: rule = fromBinVal(match.matched)
			case "decVal"		: rule = fromDecVal(match.matched)
			case "hexVal"		: rule = fromHexVal(match.matched)
			case "literal"		: rule = fromString(match)
			case "rulename"		: rule = fromRuleName(match.matched, newGrammar)
			case "coreRule"		: rule = fromCoreRule(match.matched, true)
			case "alternation"	: rule = fromAlternation(match, newGrammar)
			case "option"		: rule = fromOption(match, newGrammar)
		}

		if (rule == null)
			throw UnsupportedErr("Rule: $match.name")

		return rule
	}

	private Rule fromOption(Match match, Grammar? newGrammar) {
		rule := fromExpression(match.firstMatch, newGrammar)
		return optional(rule)
	}

	private Rule fromRepetition(Match match, Grammar? newGrammar) {
		assertName(match, "repetition")
		rule := fromExpression(match["element"].firstMatch, newGrammar)

		if (match.contains("repeat")) {
			match = match["repeat"]
		
			a := match["a"]?.matched?.trimToNull
			b := match["b"]?.matched?.trimToNull
			n := match["n"]?.matched?.trimToNull
			
			if (a == null && b == null && n == null)
				rule = zeroOrMore(rule)
			else
			if (n != null)
				rule = nTimes(n.toInt, rule)
			else
				rule = between(a?.toInt, b?.toInt, rule)
		}

		return rule
	}

	private Rule fromRuleName(Str ruleName, Grammar? newGrammar) {
		if (newGrammar == null)
			throw ParseErr("Patterns may not contain custom Grammar")
		return newGrammar[ruleName]
	}

	private Rule fromProseVal(Str ruleName, Grammar? newGrammar) {
		if (newGrammar == null)
			throw ParseErr("Patterns may not contain custom Grammar")
		return newGrammar[ruleName]
	}

	private Rule fromString(Match match) {
		match.contains("sensitive")
			? str(match["string"].matched, false)
			: str(match["string"].matched, true)
	}
	
	private Rule fromBinVal(Str val) {
		fromNumVal(val[2..-1], 2)
	}
	
	private Rule fromDecVal(Str val) {
		fromNumVal(val[2..-1], 10)
	}
	
	private Rule fromHexVal(Str val) {
		fromNumVal(val[2..-1], 16)
	}
	
	private Rule fromNumVal(Str val, Int radix) {
		if (val.contains("-")) {
			a := Int.fromStr(val.split('-')[0], radix)
			b := Int.fromStr(val.split('-')[1], radix)
			return charIn(a..b)
		}
		chars := Str.fromChars(val.split('.').map { Int.fromStr(it, radix) })
		return str(chars)
	}
	
	private Rule? fromCoreRule(Str val, Bool checked) {
		switch (val) {
			case "ALPHA"	: return alphaChar
			case "BIT"		: return charOf(['0', '1'])
			case "CHAR"		: return charRule("\u0001-\u007F")
			case "CR"		: return char(0x0D)
			case "CRLF"		: return str("\u000D\u000A")
			case "CTL"		: return charRule("\u0001-\u001F\u007F")
			case "DIGIT"	: return numChar
			case "DQUOTE"	: return char('"')
			case "HEXDIG"	: return hexChar
			case "HTAB"		: return char('\t')
			case "LF"		: return char(0x0A)
			case "LWSP"		: return zeroOrMore(firstOf([spaceChar, sequence([str("\u000D\u000A"), spaceChar])]))
			case "OCTET"	: return charRule("\u0000-\u00FF")
			case "SP"		: return char(' ')
			case "VCHAR"	: return charRule("\u0021-\u007E")
			case "WSP"		: return spaceChar
			default			: return null ?: (checked ? throw UnsupportedErr("Unknow Core Rule: $val") : null)
		}
	}
	
	private Void assertName(Match m, Str name) {
		if (m.name != name) 
			throw ParseErr("Match should be '${name}', not '${m.name}'")
	}
}
