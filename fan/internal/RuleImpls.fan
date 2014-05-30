
// ---- Terminal / String Character Rules ---------------------------------------------------------

internal class StrRule : Rule {
	override Str? 	name
	private Str		str
	private Str?	matched
	
	new make(Str str) {
		this.str = str
	}
	
	override internal Match? match(PegBuf buf) {
		matched := buf.read(str.size) |peek->Bool| { peek == str }
		return matched == null ? null : Match(name, matched)
	}
	
	override internal Void fail(PegBuf buf) {
		buf.unread(str.size)
	}
}

internal class InRangeRule : Rule {
	override Str?	name
	private Range	charRange
	private Int?	matched
	
	new make(Range charRange) {
		this.charRange = charRange
	}
	
	override internal Match? match(PegBuf buf) {
		matched := buf.readChar() |peek->Bool| { charRange.contains(peek) }
		return matched == null ? null : Match(name, matched.toChar)
	}
	
	override internal Void fail(PegBuf buf) {
		buf.unread(1)
	}
}



// ---- Rule Rules --------------------------------------------------------------------------------

internal class AtLeastRule : Rule {
	override Str?	name
	private Int		times
	private Rule	rule
	private Int		timesMatched
	
	new make(Int times, Rule rule) {
		this.times	= times
		this.rule	= rule
	}
	
	override internal Match? match(PegBuf buf) {
		matches := Match[,]
		matched := true
		while (matched) {
			match := rule.match(buf)
			if (match != null)
				matches.add(match)
			matched = (match != null)
		}
		
		timesMatched = matches.size
		if (matches.size >= times) {
			return Match(name, matches)
		} else {
			fail(buf)
			return null
		}
	}
	
	override internal Void fail(PegBuf buf) {
		timesMatched.times { rule.fail(buf) }
	}
}

internal class SequenceRule : Rule {
	override Str?	name
	private Rule[]	rules
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override internal Match? match(PegBuf buf) {
		matches := Match[,]
		matched := rules.all |rule->Bool| {
			match := rule.match(buf)
			if (match != null)
				matches.add(match)
			return (match != null)
		}

		if (matched) 
			return Match(name, matches)

		rules[0..<matches.size].each { it.fail(buf) }
		return null
	}
	
	override internal Void fail(PegBuf buf) {
		rules.each { it.fail(buf) }
	}
}

internal class FirstOfRule : Rule {
	override Str?	name
	private Rule[]	rules
	private Rule?	matched
	
	new make(Rule[] rules) {
		this.rules	= rules
	}
	
	override internal Match? match(PegBuf buf) {
		match := null
		matched = rules.find |rule->Bool| {
			match = rule.match(buf)
			return (match != null)
		}
		return match
	}
	
	override internal Void fail(PegBuf buf) {
		matched.fail(buf)
	}
}
