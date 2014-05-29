
mixin Rule {
	abstract Str? name

	internal abstract Match? match(PegBuf buf)

	internal virtual  Void pass(PegBuf buf) { }
	
	internal abstract Void fail(PegBuf buf)
	
	override Str toStr() {
		name ?: typeof.qname
	}
	
}

@Deprecated
class RuleTodo : Rule {
	override Str? name
	
	override internal Match? match(PegBuf buf) {
		null
	}
	
	override internal Void fail(PegBuf buf) { }
	
}