
class PegInStream {
	private InStream 	in
	private StrBuf		strBuf	:= StrBuf(1024)
	private Int			pos		:= 0
	
	new make(InStream in) {
		this.in 	= in
	}
	
	Str? read(Int n) {
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

	Void unread(Int n) {
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
