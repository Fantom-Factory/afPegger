
@Js
internal class ErrRule : Rule {
	private Str		msg
	
	new make(Str msg) {
		this.msg	= msg
	}
	
	override Bool doProcess(RuleCtx ctx) {
		pegErr	:= ctx.parseErr(msg)
		// allow AFX to convert PegParseErrs to AfxErrs
		newErr	:= Env.cur.index("afPegger.errFn").eachWhile |qname| {
			try	return Method.findMethod(qname, false)?.call(pegErr) as Err
			catch { /* Meh */ return null }
		} ?: pegErr
		throw newErr
	}
	
	override Str _expression() { "\\err(${msg.toCode(null)})" } 
}

** *Stolen from afPlastic*. 
@Js @NoDoc
const class PegParseErr : ParseErr {
	private const SrcCodeSnippet 	srcCode
			const Int 				errLineNo

	internal new make(SrcCodeSnippet srcCode, Int errLineNo, Str errMsg) : super(errMsg) {
		this.srcCode = srcCode
		this.errLineNo = errLineNo
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

