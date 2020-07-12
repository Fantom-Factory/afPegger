
@Js
internal class EosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos
	}
	
	override Str _expression() { "\\eos" } 
}
