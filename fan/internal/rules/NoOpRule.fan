
@Js
internal class NoOpRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(PegCtx ctx) { true }

	override Str expression() {
		"\\noop(${msg.toCode(null)})"
	}
}