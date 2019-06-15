
@Js
internal class EosRule : Rule {

	override Bool doProcess(ParseCtx ctx) {
		ctx.eos
	}
	
	override Str expression() { "\\eos" } 
}
