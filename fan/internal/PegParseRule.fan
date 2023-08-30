
// Stolen from afPlastic
** As thrown by the Err Macro.
@Js @NoDoc
const class PegParseErr : ParseErr {
	private const PegSrcSnippet srcCode
			const Int 			errLineNo

	internal new make(PegSrcSnippet srcCode, Int errLineNo, Str errMsg) : super(errMsg) {
		this.srcCode	= srcCode
		this.errLineNo	= errLineNo
	}

	@NoDoc
	override Str toStr() {
		trace := causeStr
		trace += snippetStr
		trace += "Stack Trace:"
		return trace
	}
	
	@NoDoc
	protected Str causeStr() {
		cause == null 
			? "${typeof.qname}: ${msg}" 
			: "${cause.typeof.qname}: ${msg}"
	}

	@NoDoc
	Str snippetStr() {
		snippet := "\n${typeof.name.toDisplayName}:\n"
		snippet += toSnippetStr
		return snippet
	}
	
	@NoDoc
	Str toSnippetStr() {
		srcCode.srcCodeSnippet(errLineNo, msg, 3)
	}
}
