
@Js
internal class UpperRule : Rule {
	override Bool doProcess(ParseCtx ctx) {
		ctx.readChar.isUpper
	}
	override Str expression() { "\\upper" } 
}

@Js
internal class LowerRule : Rule {
	override Bool doProcess(ParseCtx ctx) {
		ctx.readChar.isLower
	}
	override Str expression() { "\\lower" } 
}

@Js
internal class AlphaRule : Rule {
	override Bool doProcess(ParseCtx ctx) {
		peek := ctx.readChar
		return peek.isLower || peek.isUpper
	}
	override Str expression() { "\\alpha" } 
}
