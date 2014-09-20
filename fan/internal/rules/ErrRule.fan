
internal class ErrRule : Rule {
	
	new make() {
		this.name = "Error"
	}

	override Result walk(PegCtx ctx) {
		throw ParseErr("$ctx  fails=$ctx.fails")
	}
	
	override Str desc() {
		"Error"
	}
}
