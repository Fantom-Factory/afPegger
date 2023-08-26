
@Js	// End-of-Line
internal class EolRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos || ctx.readChar == '\n'
	}
	
	override Str _expression() { "\\eol" } 
}

@Js	// Start-of-Stream
internal class SosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.sos
	}
	
	override Str _expression() { "\\eos" } 
}

@Js	// End-of-Stream
internal class EosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos
	}
	
	override Str _expression() { "\\eos" } 
}
