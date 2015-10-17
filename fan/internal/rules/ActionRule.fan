
@Js
internal class ActionRule : Rule {
	
	new make(|Str|? action) {
		this.action = action
	}
	
	override Bool doProcess(PegCtx ctx) { true }
	
	override Str expression() { "-Action-" } 
}
