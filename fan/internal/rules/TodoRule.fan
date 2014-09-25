
internal class TodoRule : Rule {
	private Bool pass
	
	new make(Bool pass) {
		this.pass = pass
	}
	
	override Bool doProcess(PegCtx ctx) {
		pass
	}
	
	override Str expression() {"-TODO-"} 
}