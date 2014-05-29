
mixin Rule {
	abstract Str? name

	internal abstract Bool matches(PegBuf buf)

	internal abstract Match pass(PegBuf buf)

	internal abstract Void fail(PegBuf buf)
	
}

@Deprecated
class RuleTodo : Rule {
	override Str? name
	
	override internal Bool matches(PegBuf buf) {
		false
	}
	
	override internal Match pass(PegBuf buf) {
		Match(null, "")
	}
	
	override internal Void fail(PegBuf buf) {
	}
	
}