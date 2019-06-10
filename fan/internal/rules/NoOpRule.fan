
@Js
internal class NoOpRule : Rule {
	private Bool	pass
	private Str		msg
	
	new make(Str msg, Bool pass) {
		this.msg	= msg
		this.pass	= pass
	}
	
	override Bool doProcess(PegCtx ctx) { pass }

	override Str expression() {
		// TODO how to express a failing noop?
		"\\noop(${msg.toCode(null)})"
	}
}