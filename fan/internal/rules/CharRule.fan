
@Js
internal class CharRule : Rule {
	private		const |Int->Bool|	func
	private		const Bool			not
	private		const Str			express
	
	new make(Str expression, Bool not, |Int->Bool| func) {
		this.func 	 = func
		this.express = expression
		this.not	 = not
	}

	static new fromStr(Str charClass) {
		cClass := charClass
		ignore := cClass[-1] == 'i'
		if (ignore) cClass = cClass[0..<-1]

		if (cClass[0] != '[' && cClass[-1] != ']')
			throw ParseErr("Invalid Char class: $charClass")
		cClass = cClass[1..<-1]
		
		not := cClass[0] == '^'
		if (not) cClass = cClass[1..-1]

		try {
			chars  := Int[,]
			ranges := Range[,]
			while (cClass.size > 0) {
				if (cClass[0] == '\\') {
					if (cClass[1] == '\\')	chars.add('\\'); else
					if (cClass[1] == 'f')	chars.add('\f'); else
					if (cClass[1] == 'n')	chars.add('\n'); else
					if (cClass[1] == 'r')	chars.add('\r'); else
					if (cClass[1] == 't')	chars.add('\t'); else
					if (cClass[1] == '-')	chars.add( '-'); else
					if (cClass[1] == '^')	chars.add( '^'); else
						chars.add(cClass[1])
					cClass = cClass[2..-1]
				} else {
					start := cClass[0]
					end   := cClass.getSafe(1)
					
					if (end == '-') {
						end = cClass[2]
						ranges.add(start..end)
						cClass = cClass[3..-1]
					} else {
						chars.add(start)
						cClass = cClass[1..-1]
					}
				}
			}
			
			return CharRule(charClass.replace("[^", "["), not) |Int peek->Bool| {
				fn := chars.contains(peek) || ranges.any { it.contains(peek) }
				if (!fn && ignore) {
					peek = peek.isLower ? peek.upper : peek.lower
					fn   = chars.contains(peek) || ranges.any { it.contains(peek) }
				}
				return fn
			}
			
		} catch throw ParseErr("Invalid Char class: $charClass")
	}
	
	override Bool doProcess(PegCtx ctx) {
		chr := ctx.readChar
		res := chr == 0 ? false : func(chr)
		return not ? !res : res
	}
	
	override Str expression() {
		if (not && express.startsWith("["))
			return "[^" + express[1..-1].toCode(null)
		return (not ? "!" : "") + express.toCode(null)
	}
}
