
abstract class Rule {
	Str? 		name
	|Result|?	action

	internal abstract Result walk(PegCtx ctx)
	
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

	override Result walk(PegCtx ctx) {
		Result("TODO")
	}
	
	override Str desc() {"-!TODO!-"} 
}