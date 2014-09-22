
internal class TodoRule : Rule {
	private Bool pass
	
	new make(Bool pass) {
		this.pass = pass
	}
	
	override Result match(PegCtx ctx) {
		result := Result("TODO")
		if (pass)
			result.successFunc = |->| { }
		return result
	}
	
	override Str desc() {"-!TODO!-"} 
}