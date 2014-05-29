
internal class PegBuf {
	private InStream 	in
	private StrBuf		strBuf
	private Int			pos
	
	new make(InStream in) {
		this.in 	= in
		this.strBuf	= StrBuf()
		this.pos	= 0
	}
	
	Int readChar() {
		read(1).chars.first
	}

	Str read(Int n) {
		noOfCharsLeftInBuf	:= strBuf.size - pos 
		noToReadFromIn		:= n - noOfCharsLeftInBuf 
		if (noToReadFromIn > 0)
			strBuf.add(in.readChars(n))
		pos += n
		return strBuf[pos-n..<pos]
	}

	Void unread(Int n) {
		pos -= n
		if (pos < 0)
			throw Err("WTF!? Peg has a pos of ${pos}!!!")
	}
}
