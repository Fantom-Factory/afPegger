
abstract class Rule {
	Str? 		name
	|Match|?	action

	internal abstract Match? match(PegCtx ctx)

	internal virtual  Void pass(Match match) { 
		action?.call(match)
	}
	
	internal abstract Void fail(PegCtx ctx)

	internal abstract This dup()

	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
}

@Deprecated
class RuleTodo : Rule {
	
	override internal Match? match(PegCtx ctx) {
		null
	}
	
	override internal Void fail(PegCtx ctx) { }
	
	override Str desc() {"-!TODO!-"} 

	override This dup() { this } 
}