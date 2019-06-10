
@Js
internal class ErrRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(PegCtx ctx) {
		// TODO add lineNum and afPlastic::SrcCodeSnippet
		throw PegParseErr(msg)
	}
	
	override Str expression() { "\\err(${msg.toCode(null)})" } 
}

@Js @NoDoc
const class PegParseErr : ParseErr {
	internal new make(Str msg) : super(msg) { }
}
