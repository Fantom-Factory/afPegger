
abstract class Rule {
	Str? 		name
	|Result|?	action

	abstract protected Void doProcess(PegCtx ctx)
	
	abstract Str expression()

	Str definition() {
		((name == null) ? Str.defVal : "${name} <- ") + expression		
	}
	
	override Str toStr() {
		name ?: expression
	}
	
//	Void addAction(|Match| action) {
//		this.action = action
//	}
}
