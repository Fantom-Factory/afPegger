
** Parsing Expression Grammar (PEG)
** 
@Js
class Peg {
	private PegCtx	pegCtx
	private Rule	rule
	
	** Creates a PEG class ready to match the given string and rule.
	new makeRule(Str str, Rule rule) {
		this.rule	= rule
		this.pegCtx	= PegCtx(str, rule)
	}

	** Parses the given PEG pattern in to a rule.
	** Convenience for:
	** 
	**   syntax: fantom 
	**   Peg(str, Peg.parseRule(pattern))
	** 
	** See `Rule.parseRule`
	new makePattern(Str str, Str rulePattern) {
		this.rule	= Peg.parseRule(rulePattern)
		this.pegCtx	= PegCtx(str, rule)
	}

	// ---- Static methods ----
	
	** Turns debug messaging on and off.
	static Void debugOn(Bool debug := true) {
		Peg#.pod.log.level = (debug ? LogLevel.debug : LogLevel.info)
	}
	
	** Parses a pattern in to simple rule.
	** For example:
	** 
	**   syntax: fantom 
	**   parseRule("[abc] / [xyz]")
	** 
	** See `Rule.parseRule`
	static Rule parseRule(Str pattern) {
		PegGrammar().parseRule(pattern)
	}
	
	** Parses a list of PEG grammar definitions.
	** For example:
	** 
	**   syntax: fantom 
	**   parseGrammar("a <- [abc] / [xyz] / b
	**                 b <- \space+ [^abc]")
	** 
	** See `Grammar.parseGrammar`
	static Grammar parseGrammar(Str grammar) {
		PegGrammar().parseGrammar(grammar)
	}
	
	** Returns the grammar PEG used to parse PEG grammar.
	** 
	** It's not particularly useful, but it may be interesting to some.
	static Grammar pegGrammar() {
		PegGrammar.pegGrammar
	}
	
	// ---- Instance methods ----

	** Returns the matched text of the next PEG match, optionally returning the contents of the given label. 
	** 
	**   syntax: fantom
	**   peg := Peg("a12 + b23 / c69 * z666", "foo:[a-z] [0-9]+")
	**   peg.find         // --> "a12"
	**   peg.find         // --> "b23"
	**   peg.find("foo")  // --> "c"
	**   peg.find("foo")  // --> "z"
	** 
	** See [matched()]`matched` to match against the entire string.
	Str? find(Str? label := null, Int? offset := null) {
		match := search(offset)
		return label == null ? match?.matched : match?.findMatch(label)?.matched
	}
	
	** Searches for the next PEG match and replaces a portion of it.
	** 
	** 'replacements' is a map of label names to replacement values.
	** 
	** Use the label 'root' to replace the entire Match.
	** 
	** Use standard '${interpolation}' in values to reference other matched labels.
	** Interpolation may be escaped with a backslash - '\${not interpolated}'.
	** 
	**   syntax: fantom
	**   str := "(34) -> {12}"
	**   pat := "foo:[0-9]+ [^0-9]+ bar:[0-9]+"
	**   peg := Peg(str, pat)
	**   val := peg.replace(["foo":"\${bar}", "bar":"\${foo}"])
	**       // --> (12) -> {34}
	** 
	Str replace(Str:Str replacements, Int? offset := null) {
		match := search(offset)
		if (match == null)
			return pegCtx.str
	
		str := StrBuf(pegCtx.str.size).add(pegCtx.str)
		doReplace(str, match, replacements)
		return str.toStr
	}
	
	** Replaces all occurrences of a PEG match.
	** 
	** 'replacements' is a map of label names to replacement values.
	** 
	** Use the label 'root' to replace the entire Match.
	** 
	** Use standard '${interpolation}' in values to reference other matched labels.
	** Interpolation may be escaped with a backslash - '\${this is not interpolated}'.
	**
	**   syntax: fantom
	**   str := "I like abba!"
	**   pat := "foo:'a' / bar:'b'"
	**   peg := Peg(str, pat)
	**   val := peg.replaceAll(["foo":"b", "bar":"a"])
	**       // --> I like baab!
	** 
	Str replaceAll(Str:Str replacements, Int? offset := null) {
		matches := Match[,]
		each |m| { matches.add(m) }
		
		str := StrBuf(pegCtx.str.size).add(pegCtx.str)
		// process the actual replacements in reverse order
		matches.eachr |m| {
			doReplace(str, m, replacements)
		}
		return str.toStr
	}
	
	** Searches for the next PEG match (optionally with the given label) and returns the matched string (if any).
	** 
	** Returns 'null' if there are no more matches.
	Match? search(Int? offset := null) {
		if (offset != null)
			pegCtx.rollbackToPos(offset)

		m := null as Match
		while (m == null && !pegCtx.eos) {
			m = match
			if (m == null)
				pegCtx.rollbackToPos(pegCtx.cur	+ 1)
		}
		
		return m
	}
	
	** Returns all matches from the given offset.
	Match[] searchAll(Int? offset := null) {
		if (offset != null)
			pegCtx.rollbackToPos(offset)

		matches := Match[,]
		match   := null as Match
		while ((match = search) != null) {
			matches.add(match)
		}
		return matches
	}

	** Returns 'true' if the string contains a PEG match.
	** Convenience for:
	**  
	**   fantom: syntax
	**   search != null
	** 
	** See [matches()]`matches` to check for a match against the entire string.
	Bool contains() {
		search != null
	}
	
	** Performs a PEG match against the entire string (from the given offset) - use for matching grammars.
	** 
	** See [search()]`search` to *search* for a match anywhere in the string. 
	Match? match(Int? offset := null) {
		if (offset != null) {
			if (offset < 0 || offset >= pegCtx.str.size)
				throw ArgErr("Offset '${offset}' is out of bounds: 0 >= offset >= ${pegCtx.str.size-1}")
			pegCtx.rollbackToPos(offset)
		}

		// it's important to search() that we do NOT roll-back to position 0 

		return pegCtx.clearResults.process(rule)
			? pegCtx.doSuccess
			: null
	}
	
	** Performs a PEG match against the entire string.
	** Returns 'true' if it matches.
	** 
	** See [contains()]`contains` to *search* for a match instead.
	Bool matches() {
		match != null
	}
	
	** Performs a PEG match against the entire string.
	** Returns the matched string.
	** 
	** See [find()]`find` to *search* for a match anywhere in the string.
	Str? matched() {
		match?.matched
	}
	
	** Searches the string and calls the given function for each PEG Match found.
	** 
	** Also see [search()]`search`, and [eachWhile()]`eachWhile`.
	Void each(|Match| fn) {
		c := 0
		while (c < pegCtx.str.size) {
			m := match(c)
			if (m != null) {
				fn(m)
				c = pegCtx.cur
			} else
				c++
		}
	}

	** Searches the string and calls the given function for each PEG Match found, until a non-null result is returned.
	** Returns 'null' if there are no matches.
	** 
	** Also see [search()]`search`, and [each()]`each`.
	Obj? eachWhile(|Match->Obj?| fn) {
		r := null
		c := 0
		while (r == null && c < pegCtx.str.size) {
			m := match(c)
			if (m != null) {
				r = fn(m)
				c = pegCtx.cur
			} else
				c++
		}
		return r
	}
	
	private Regex interpolex := "[^\\\\]?\\\$\\{([^}]+)\\}".toRegex
	private Void doReplace(StrBuf str, Match match, Str:Str replacements) {
		matched := Match[,]
		replacements.each |to, from| {
			fromM := match.findMatch(from)
			if (fromM != null)
				matched.add(fromM)
		}

		// reverse the order, to process replacements from the end
		// so we don't mess up the str / ranges for the next replace
		matched.sortr |m1, m2| { m1.matchedRange.start <=> m2.matchedRange.start }

		matched.each |fromM| {
			to := replacements[fromM.name]

			// do the interpolation of replacement values
			interpols := Range:Str[:]
			interpols.ordered = true
			rm := interpolex.matcher(to)
			while (rm.find) {
				label := rm.group(1)
				repla := match.findMatch(label)?.matched ?: ""
				interpols[rm.start(0)..<rm.end(0)] = repla
			}
			toBuf := StrBuf(to.size).add(to)
			keys  := interpols.keys.sortr |i1, i2| { i1.start <=> i2.start }
			keys.each |r| {
				val := interpols[r]
				toBuf.replaceRange(r, val)
			}
			to = toBuf.toStr

			// do the replacement
			str.replaceRange(fromM.matchedRange, to)
		}
	}
}
