
internal class PegBuf {
	private InStream 	in
	private StrBuf		strBuf
	private Int			pos
	
	new make(InStream in) {
		this.in 	= in
		this.strBuf	= StrBuf()
		this.pos	= 0
	}
	
//	Bool hasMore() {
//		(strBuf.size - pos > 0) || in.peekChar != null
//	}
	
	Str? read(Int n, |Str peek->Bool| c) {
		peek := readChars(n)
		if (peek == null)
			return null

		if (!c(peek)) {
			peek = null
			unread(n)
		}
		return peek
	}

	Int? readChar(|Int peek->Bool| c) {
		peek := readChars(1)
		if (peek == null)
			return null

		char := (Int?) peek.chars.first
		if (!c(char)) {
			char = null
			unread(1)
		}
		return char
	}

	Void unread(Int n) {
		pos -= n
		if (pos < 0)
			throw Err("WTF!? Peg has a pos of ${pos}!!!")
	}

	private Str? readChars(Int n) {
		noOfCharsLeftInBuf	:= strBuf.size - pos 
		noToReadFromIn		:= n - noOfCharsLeftInBuf 
		while (noToReadFromIn > 0) {
			if (in.peekChar == null)
				return null
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
