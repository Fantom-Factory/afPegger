
@Js
internal class EosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos
	}
	
	override Str expression() { "\\eos" } 
}
