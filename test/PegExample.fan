
@Js
class PegExample : Test {
	
	Void testBasics() {
		part	:= Rules.oneOrMore(Rules.charIn('0'..'9'))
		int		:= part 										{ it.name = "int" }
		real	:= Rules.sequence([part, Rules.str("."), part])	{ it.name = "real" }
		number	:= Rules.firstOf([real, int])					{ it.name = "number" }
		wspace	:= Rules.zeroOrMore(Rules.str(" "))

		match	:= Rules.sequence([number, wspace])				{ it.name = "match" }
		numbers	:= Rules.oneOrMore(Rules.sequence([number, wspace])){ it.name = "numbers" }

		in		:= "75 33.23 11"
		verifyEq(in, Peg(in, numbers).matched)
		
		peg		:= Peg(in, match)
		verifyEq("75 "	 , peg.matched)
		verifyEq("33.23 ", peg.matched)
		verifyEq("11"	 , peg.matched)
	}

	Void testSearch() {
		peg		:= Peg("--a---bb----ccc-----dddd------eeeee--", Rules.oneOrMore(Rules.alphaChar))
		verifyEq("a",		peg.find)
		verifyEq("bb",		peg.find)
		verifyEq("ccc",		peg.find)
		verifyEq("dddd",	peg.find)
		verifyEq("eeeee",	peg.find)
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
		mat := null as Match
		val := Str[,]
		while ((mat = peg.search) != null)
			val.add(mat["a"].matched)

		verifyEq(val, ["foo", "bar", "meh wotever"])
	}
}
