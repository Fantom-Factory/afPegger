
abstract class Rule {
	Str? 		name
	|Match|?	action

	internal abstract Match? match(PegCtx ctx)

	internal virtual  Void walk(Match match) { 
		action?.call(match)
	}
	
	internal abstract Void rollback(PegCtx ctx)

	abstract This dup()

	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
	Void addAction(|Match| action) {
		this.action = action
	}
}

@Deprecated
class RuleTodo : Rule {
	
	override internal Match? match(PegCtx ctx) {
		null
	}
	
	override internal Void rollback(PegCtx ctx) { }
	
	override Str desc() {"-!TODO!-"} 

	override This dup() { this } 
}