
** As thrown by Pegger.
const class PegErr : Err {
	
	** A trace of PEG operations that led to the Err. 
	** A succinct and more informative stack trace if you will.
	const Str? operationTrace
	
	internal new make(Str msg := "", Err? cause := null, Str? opTrace := null) : super(msg, cause) {
		this.operationTrace = opTrace
	}
	
	@NoDoc
	override Str toStr() {
		opTrace := causeStr
		opTrace += opTraceStr
		opTrace += "Stack Trace:"
		return opTrace
	}
	
	@NoDoc
	protected Str causeStr() {
		opTrace := (cause == null) 
				? "${typeof.qname}: " 
				: (cause is PegErr ? "" : "${cause.typeof.qname}: ")
		opTrace += msg		
		return opTrace
	}

	@NoDoc
	protected Str opTraceStr() {
		opTrace := ""
		if (operationTrace != null && !operationTrace.isEmpty) {
			opTrace += "\nIoc Operation Trace:\n"
			operationTrace.splitLines.each |op, i| { 
				opTrace += ("  [${(i+1).toStr.justr(2)}] $op\n")
			}
		}
		return opTrace
	}
}
