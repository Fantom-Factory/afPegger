
internal class PegCtx {
	private InStream 	in
	private StrBuf		strBuf	:= StrBuf(1024)
	private Int			pos		:= 0
	private Bool		eos
			Obj[]		stack	:= Obj[,]
			Str[]		fails	:= Str[,]
	
	new make(InStream in) {
		this.in 	= in
	}
	
	Str? matchStr(Int n, |Str peek->Bool| c) {
		peek := readChars(n)
		if (peek == null)
			return null
		return c(peek) ? peek : null
	}	
	
	Str? read(Rule rule, Int n, |Str peek->Bool| c) {
		oPos := pos
		peek := readChars(n)
		if (peek == null)
			return null

		if (!c(peek)) {
			if (!eos)
				fails.add("${rule} did not match ${peek}")
			peek = null
			pos = oPos
		}
		return peek
	}

	Int? readChar(Rule rule, |Int peek->Bool| c) {
		oPos := pos
		peek := readChars(1)
		if (peek == null)
			return null

		char := (Int?) peek.chars.first
		if (!c(char)) {
			if (!eos)
				fails.add("${rule} did not match ${peek}")
			char = null
			pos = oPos
		}
		return char
	}

	Void unread(Int n) {
		pos -= n
		if (pos < 0)
			throw Err("WTF!? Peg has a pos of ${pos}!!!")
	}

	Void fail(Rule rule, Int chars := 20) {
		if (eos) return
		oPos := pos
		peek := readChars(chars)
		fails.add("${rule} did not match ${peek}...")		
		pos = oPos
	}
	
	internal Void close() {
		in.close
	}
	
	private Str? readChars(Int n) {
		noOfCharsLeftInBuf	:= strBuf.size - pos 
		noToReadFromIn		:= n - noOfCharsLeftInBuf 
		while (noToReadFromIn > 0) {
			if (in.peekChar == null) {
				if (!eos)
					fails.add("EOS - End Of Stream")
				eos = true
				return null
			}
			strBuf.addChar(in.readChar)
			noToReadFromIn--
		}
		str := strBuf[pos..<pos+n]
		pos += n
		return str
	}
	
	override Str toStr() {
		"pos:${pos}, buf:${strBuf}"
	}
}
