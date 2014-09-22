
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
