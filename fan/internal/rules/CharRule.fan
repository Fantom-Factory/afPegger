
@Js
internal class CharRule : Rule {
	private		const |Int->Bool|	func
	private		const Bool			not
	private		const Str			express
	
	new make(Str expression, Bool not, |Int->Bool| func) {
		this.func 	 = func
		this.express = expression
		this.not	 = not
	}

	override Bool doProcess(PegCtx ctx) {
		chr := ctx.readChar
		res := chr == 0 ? false : func(chr)
		return not ? !res : res
	}
	
	override Str expression() {
		if (not && express.startsWith("["))
			return "[^" + express[1..-1].toCode(null)
		return (not ? "!" : "") + express.toCode(null)
	}
}
