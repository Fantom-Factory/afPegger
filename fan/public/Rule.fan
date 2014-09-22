
abstract class Rule {
	Str? 		name
	internal |Result|?	action

	abstract Result walk(PegInStream in)
	
	abstract Str desc()
	
	override Str toStr() {
		((name == null) ? Str.defVal : "${name} <- ") + desc
	}
	
//	Void addAction(|Match| action) {
//		this.action = action
//	}
}
