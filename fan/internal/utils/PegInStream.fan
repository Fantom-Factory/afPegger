
** This class saves us some 200ms on a FantomFactory parse
internal class PegInStream {
	private InStream 	in
	private StrBuf		strBuf	:= StrBuf(1024)
	private Int			pos		:= 0
	
	new make(InStream in) {
		this.in 	= in
	}
	
	Str? readChar(Int n) {
		noOfCharsLeftInBuf	:= strBuf.size - pos

		if (n == 1 && noOfCharsLeftInBuf >= 1)
			return strBuf[pos++].toChar

		noToReadFromIn		:= n - noOfCharsLeftInBuf
		while (noToReadFromIn > 0) {
			char := in.readChar
			if (char != null)
				strBuf.addChar(char)
			else
				n--
			noToReadFromIn--
		}
		str := strBuf[pos..<pos+n]
		pos += n
		return str
	}

	Void unreadChar(Int n) {
		pos -= n
		if (pos < 0)
			throw Err("WTF!? Peg has a pos of ${pos}!!!")
	}

	Void close() {
		in.close
	}

	override Str toStr() {
		"pos:${pos}, buf:${strBuf}"
	}
}
