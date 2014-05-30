
class PegExample : Test, Rules {
	
	Void testBasics() {
		part	:= oneOrMore(inRange('0'..'9'))
		int		:= part 								{ it.name = "int" }
		real	:= sequence([part, str("."), part])		{ it.name = "real" }
		number	:= firstOf([real, int])					{ it.name = "number" }
		wspace	:= zeroOrMore(str(" "))

		match	:= sequence([number, wspace])			{ it.name = "match" }
		numbers	:= oneOrMore(sequence([number, wspace])){ it.name = "numbers" }

//		parser := Parser(numbers, "75 33.23 11".in)
		parser := Parser(match, "75 33.23 11".in)

		Env.cur.err.printLine(parser.parse)
		Env.cur.err.printLine(parser.parse)
		Env.cur.err.printLine(parser.parse)
	}
}
