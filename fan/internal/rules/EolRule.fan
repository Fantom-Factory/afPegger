
@Js
internal class EolRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos || ctx.readChar == '\n'
	}
	
	override Str _expression() { "\\eol" } 
}
