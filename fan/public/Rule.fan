
abstract class Rule {
	Str? 		name
	internal |Result|?	action

	internal abstract Result walk(PegCtx ctx)
	
	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
//	Void addAction(|Match| action) {
//		this.action = action
//	}
}

@Deprecated
internal class RuleTodo : Rule {

	override Result walk(PegCtx ctx) {
		Result("TODO")
	}
	
	override Str desc() {"-!TODO!-"} 
}