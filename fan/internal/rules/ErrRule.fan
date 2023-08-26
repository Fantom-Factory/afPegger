
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
