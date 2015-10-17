
@Js
internal class EosRule : Rule {

	override Bool doProcess(PegCtx ctx) {
		char := ctx.readChar
		if (char == null)
			return true
		ctx.unreadStr(char.toChar)
		return false
	}
	
	override Str expression() { "EOS" } 
}
