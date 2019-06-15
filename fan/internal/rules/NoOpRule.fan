
@Js
internal class NoOpRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(RuleCtx ctx) {
		echo("NoOp Rule: $msg")
		ctx.log("NO-OP: $msg")
		return true
	}

	override Str expression() {
		"\\noop(${msg.toCode(null)})"
	}
}