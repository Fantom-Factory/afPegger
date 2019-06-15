
@Js
internal class EolRule : Rule {

	override Bool doProcess(ParseCtx ctx) {
		ctx.eos || ctx.readChar == '\n'
	}
	
	override Str expression() { "\\eol" } 
}
