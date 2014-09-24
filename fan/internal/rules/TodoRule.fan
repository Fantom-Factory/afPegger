
internal class TodoRule : Rule {
	private Bool pass
	
	new make(Bool pass) {
		this.pass = pass
	}
	
	override Void doProcess(PegCtx ctx) {
		ctx.pass(pass)
	}
	
	override Str expression() {"-TODO-"} 
}