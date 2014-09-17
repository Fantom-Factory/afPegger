
internal class StrRule : Rule {
	private Str			str
	private Str?		matched
	
	new make(Str str) {
		this.str = str
	}
	
	override internal Match? match(PegCtx ctx) {
		matched := ctx.read(this, str.size) |peek->Bool| { peek == str }
		return matched == null ? null : Match(name, matched)
	}
	
	override internal Void rollback(PegCtx ctx) {
		ctx.unread(str.size)
	}
	
	override Str desc() {
		"\"${str}\""
	}

	override This dup() { 
		StrRule(str) { it.name = this.name; it.action = this.action }
	} 
}




