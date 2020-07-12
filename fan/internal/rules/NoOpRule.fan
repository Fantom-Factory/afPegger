
@Js
internal class NoOpRule : Rule {
	private Bool	pass
	
	new make(Bool pass) {
		this.pass	= pass
	}
	
	override Bool doProcess(RuleCtx ctx) {
		return pass
	}

	override Str expression() {
		"\\noop(${pass})"
	}
}
