
class PegExample : Grammer {
	
	Void main() {
		part	:= oneOrMore(inRange('0'..'9'))
		int		:= part
		real	:= sequence([part, str("."), part])
		number	:= firstOf([real, int])
		wspace	:= zeroOrMore(str(" "))
		numbers	:= oneOrMore(sequence([number, wspace]))

		match := Parser(numbers, "75 33.23 11".in).parse
		
		Env.cur.err.printLine(match)
	}
}
