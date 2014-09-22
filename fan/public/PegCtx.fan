
class PegCtx {
	private PegInStream pegStream
	
	internal new make(PegInStream pegStream) {
		this.pegStream = pegStream
	}
	
	Str? read(Int n) {
		pegStream.read(n) 
	}

	Void unread(Int n) {
		pegStream.unread(n) 
	}

	Void close() {
		pegStream.close
	}
	
}
