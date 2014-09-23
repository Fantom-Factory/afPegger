
abstract class Rule {
	Str? 		name
	|Result|?	action

	abstract protected Void doProcess(PegCtx ctx)
	
	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
//	Void addAction(|Match| action) {
//		this.action = action
//	}
}
