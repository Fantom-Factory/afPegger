
abstract class Rule {
	virtual Str? 		name
	virtual |Result|?	action

	abstract protected Void doProcess(PegCtx ctx)
	
	// TODO: introduce grammer field
	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
//	Void addAction(|Match| action) {
//		this.action = action
//	}
}
