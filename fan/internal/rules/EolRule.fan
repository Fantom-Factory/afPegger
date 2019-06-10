
@Js
internal class EosRule : Rule {

	override Bool doProcess(PegCtx ctx) {
		ctx.eos
	}
	
	override Str expression() { "\\eos" } 
}
