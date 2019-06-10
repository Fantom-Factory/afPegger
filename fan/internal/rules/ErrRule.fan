
@Js internal class ErrRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(PegCtx ctx) {
		throw Err(msg)
	}
	
	override Str expression() { "\\err(${msg.toCode(null)})" } 
}
