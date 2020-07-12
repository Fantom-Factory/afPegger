
@Js
internal class DumpRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(RuleCtx ctx) {
		echo("DUMP: $msg")
		ctx.log("DUMP: $msg")
		return true
	}

	override Str _expression() {
		"\\dump(${msg.toCode(null)})"
	}
}