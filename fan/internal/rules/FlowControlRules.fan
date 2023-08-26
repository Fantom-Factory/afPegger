
@Js
internal class PassRule : Rule {
	
	override Bool doProcess(RuleCtx ctx) { true }

	override Str _expression() { "\\pass" }
}

@Js
internal class FailRule : Rule {
	
	override Bool doProcess(RuleCtx ctx) { false }

	override Str _expression() { "\\fail" }
}
