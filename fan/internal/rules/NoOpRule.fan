
@Js
internal class NoOpRule : Rule {
	private Bool pass
	override Str expression
	
	new make(Str exp, Bool pass) {
		this.expression = exp
		this.pass = pass
	}
	
	override Bool doProcess(PegCtx ctx) { pass }
}