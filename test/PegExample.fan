
@Js
class PegExample : Test, Rules {
	
	Void testBasics() {
		part	:= oneOrMore(charIn('0'..'9'))
		int		:= part 								{ it.name = "int" }
		real	:= sequence([part, str("."), part])		{ it.name = "real" }
		number	:= firstOf([real, int])					{ it.name = "number" }
		wspace	:= zeroOrMore(str(" "))

		match	:= sequence([number, wspace])			{ it.name = "match" }
		numbers	:= oneOrMore(sequence([number, wspace])){ it.name = "numbers" }

		in		:= "75 33.23 11"
		verifyEq(in, Peg(in, numbers).matched)
		
		peg		:= Peg(in, match)
		verifyEq("75 "	 , peg.matched)
		verifyEq("33.23 ", peg.matched)
		verifyEq("11"	 , peg.matched)
	}

	Void testSearch() {
		peg		:= Peg("--a---bb----ccc-----dddd------eeeee--", oneOrMore(alphaChar))
		verifyEq("a",		peg.search)
		verifyEq("bb",		peg.search)
		verifyEq("ccc",		peg.search)
		verifyEq("dddd",	peg.search)
		verifyEq("eeeee",	peg.search)
	}
	
	Void testDocGrammarExample() {
		grammar := Peg.parseGrammar("element  = startTag (element / text)* endTag
		                             startTag = '<'  name:[a-z]i+ '>'
		                             endTag   = '</' name:[a-z]i+ '>'
		                             text     = [^<]+")
		
		html    := "<html><head><title>Pegger Example</title></head><body><p>Parsing is Easy!</p></body></html>"
		
		grammar["element"].match(html)
	}
	
	Void testFilter() {
		peg := Peg("foo bar \"meh wotever\" ", """ ('"' a:[^"]+ '"') / a:[^ ]+ """)
		str := null as Str
		val := Str[,]
		while ((str = peg.search("a")) != null)
			val.add(str)
		
		verifyEq(val, ["foo", "bar", "meh wotever"])
	}
}
