
@Js
internal class EolRule : Rule {

	override Bool doProcess(PegCtx ctx) {
		ctx.eos || ctx.readChar == '\n'
	}
	
	override Str expression() { "\\eol" } 
}
