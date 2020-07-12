
@Js
internal class UpperRule : Rule {
	override Bool doProcess(RuleCtx ctx) {
		ctx.readChar.isUpper
	}
	override Str _expression() { "\\upper" } 
}

@Js
internal class LowerRule : Rule {
	override Bool doProcess(RuleCtx ctx) {
		ctx.readChar.isLower
	}
	override Str _expression() { "\\lower" } 
}

@Js
internal class AlphaRule : Rule {
	override Bool doProcess(RuleCtx ctx) {
		peek := ctx.readChar
		return peek.isLower || peek.isUpper
	}
	override Str _expression() { "\\alpha" } 
}
