
@Js
internal class NoOpRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(PegCtx ctx) {
		echo("NoOp Rule: $msg")
		return true
	}

	override Str expression() {
		"\\noop(${msg.toCode(null)})"
	}
}