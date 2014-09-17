
internal class ProxyRule : Rule {
	private |Obj?->Rule|	func
	
	new make(|Obj?->Rule| func) {
		this.func = func
	}
	
	override internal Match? match(PegCtx ctx) {
		rule.match(ctx)
	}
	
	override internal Void rollback(PegCtx ctx) {
		rule.rollback(ctx)
	}
	
	override Str desc() {
		rule.desc
	}

	override This dup() { 
		ProxyRule(func)
	}
	
	private once Rule rule() {
		func(null)
	}
}




