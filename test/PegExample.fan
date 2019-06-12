
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
}
