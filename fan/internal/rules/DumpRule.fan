
@Js @Deprecated
internal class DumpRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(RuleCtx ctx) {
		echo("Dump Rule: $msg")
		ctx.log("DUMP: $msg")
		return true
	}

	override Str expression() {
		"\\noop(${msg.toCode(null)})"
	}
}