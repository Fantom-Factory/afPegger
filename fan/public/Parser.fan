
** The main parser class; use to run your rules against an 'InStream'. 
@Js
class Parser {
	private Rule 		rootRule
	
	** Create a 'Parser' with the given root 'Rule'.
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}

	** Runs the parsing rules against characters in the given 'InStream'.
	** The given 'ctx' object is passed to all successful actions, and returned.
	Obj? parse(InStream in, Obj? ctx := null, Bool checked := true) {
		pegCtx	:= PegCtx(rootRule, in)
		result	:= pegCtx.process(rootRule)
		if (result)
			pegCtx.rootResult.success(ctx)
		else if (checked)
			throw ParseErr("InStream did not match Pegger rules")
		return ctx
	}

	** Continually parses the given 'InStream' until the end of the stream is reached, or nothing was matched.
	** Returns the given action 'ctx' object.
	Obj? parseAll(InStream in, Obj? ctx := null, Bool checked := true) {
		Int? b := 69
		Bool parsed := true
		// can't do this in JS - see http://fantom.org/forum/topic/2445
//		while (parsed && (b = in.readChar) != null) { ... }
		while (parsed && b != null) {
			b = in.peekChar
			if (b != null)
				parsed = matches(in, ctx)
		}
		
		if (checked && parsed.not)
			throw ParseErr("InStream did not match Pegger rules")

		return ctx
	}

	** Runs the parsing rules against characters in the given 'InStream'.
	** Returns the characters (if any) that were matched.
	Str? match(InStream in, Obj? ctx := null) {
		pegCtx	:= PegCtx(rootRule, in)
		result	:= pegCtx.process(rootRule)
		if (result)
			pegCtx.rootResult.success(ctx)
		return result ? pegCtx.rootResult.matched : null
	}
	
	** Runs the parsing rules against characters in the given 'InStream'.
	** Returns 'true' if anything was matched.
	** 
	** Convenience for 'match(in, ctx) != null'
	Bool matches(InStream in, Obj? ctx := null) {
		match(in, ctx) != null
	}
}
