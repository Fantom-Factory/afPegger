
@Js	// Start-of-Stream
internal class SosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.sos
	}
	
	override Str _expression() { "\\sos" } 
}

@Js	// End-of-Stream
internal class EosRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos
	}
	
	override Str _expression() { "\\eos" } 
}

@Js	// Start-of-Line
internal class SolRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.sos || ctx.peekChar(-1) == '\n'
	}
	
	override Str _expression() { "\\sol" } 
}

@Js	// End-of-Line
internal class EolRule : Rule {

	override Bool doProcess(RuleCtx ctx) {
		ctx.eos || ctx.peekChar == '\n'
	}
	
	override Str _expression() { "\\eol" } 
}
