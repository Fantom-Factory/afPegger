
internal class CharRule : Rule {
	private  |Int->Bool|	func
	private  Str?			matched
	private  Str			str
	
	new make(Str str, |Int peek->Bool| func) {
		this.str  = str
		this.func = func
	}

	override internal Match? match(PegCtx ctx) {
		matched := ctx.readChar(this, func)
		return matched == null ? null : Match(name, matched.toChar)
	}
	
	override internal Void rollback(PegCtx ctx) {
		ctx.unread(1)
	}
	
	override Str desc() {
		str
	}
	
	override This dup() { 
		CharRule(str, func) { it.name = this.name; it.action = this.action }
	} 
}
