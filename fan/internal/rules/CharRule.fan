
** This is its own rule class to override the expression
@Js
internal class AnyCharRule : Rule {
	override Str expression	:= "."	
	override Bool doProcess(RuleCtx ctx) {
		ctx.readChar != 0
	}
}

** This is its own rule class to override the expression
@Js
internal class StrMimickCharRule : Rule {
	private const Int	char
	private const Bool	ignoresCase

	new make(Int char, Bool caseInsensitive) {
		this.char		 = char
		this.ignoresCase = caseInsensitive
	}

	override Bool doProcess(RuleCtx ctx) {
		peek := ctx.readChar
		pass := peek == char
		if (!pass && ignoresCase) {
			peek = peek.isLower ? peek.upper : peek.lower
			pass = peek == char
		}
		return pass
	}

	override Str expression() {
		char.toChar.toCode + (ignoresCase ? "i" : "")
	}
	
	override Str typeName() {
		"charRule"
	}
}

@Js
internal class CharRule : Rule {
	private		const |Int->Bool|	func
	private		const Bool			not
	private		const Str			express
	internal		  Bool			ignoresCase
	
	new make(Str expression, Bool not, |Int->Bool| func) {
		this.func 	 = func
		this.express = expression
		this.not	 = not
	}

	static Rule fromStr(Str charClass) {
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

			unicode := |->Int| {
				hex := cClass[2..<6]
				cClass = cClass[4..-1]
				return Int.fromStr(hex, 16)
			}
			
			ranges := Range[,]
			while (cClass.size > 0) {
				if (cClass[0] == '\\') {
					if (cClass[1] == '\\')	chars.add('\\'); else
					if (cClass[1] == 'b')	chars.add('\b'); else
					if (cClass[1] == 'f')	chars.add('\f'); else
					if (cClass[1] == 'n')	chars.add('\n'); else
					if (cClass[1] == 'r')	chars.add('\r'); else
					if (cClass[1] == 't')	chars.add('\t'); else
					if (cClass[1] == '-')	chars.add( '-'); else
					if (cClass[1] == '^')	chars.add( '^'); else
					if (cClass[1] == 'u')	chars.add(unicode()); else
						// may as well allow ALL chars to be escaped
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
			
			if (ranges.isEmpty && chars.size == 1 && !not)
				return StrMimickCharRule(chars.first, ignore)

			express := ranges.join("") { it.start.toChar + "-" + it.end.toChar } + chars.join("") { it.toChar }.toCode(null).replace("]", "\\]").replace("-", "\\-") 
			return CharRule(express, not) |Int peek->Bool| {
				fn := chars.contains(peek) || ranges.any { it.contains(peek) }
				if (!fn && ignore) {
					peek = peek.isLower ? peek.upper : peek.lower
					fn   = chars.contains(peek) || ranges.any { it.contains(peek) }
				}
				return fn
			} { it.ignoresCase = ignore }
			
		} catch throw ParseErr("Invalid Char class: $charClass")
	}
	
	override Bool doProcess(RuleCtx ctx) {
		if (ctx.eos) return false
		res := func(ctx.readChar)
		return not ? !res : res
	}
	
	override Str expression() {
		"[" + (not ? "^" : "") + express + "]" + (ignoresCase ? "i" : "")
	}
}
