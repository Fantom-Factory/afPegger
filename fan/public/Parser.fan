
** The main parser class; use to run your rules against an 'InStream'. 
@Js
class Parser {
	private Rule 		rootRule
	
	** Create a 'Parser' with the given root 'Rule'.
	new make(Rule rootRule) {
		this.rootRule 	= rootRule
	}
	
	// FIXME: rename to match() -> then fix all the tests!
	// TODO: parser to return actionCtx -> then fix all the tests!
	** Runs the parsing rules against the characters in the given 'InStream'.
	Str? parse(InStream in, Obj? actionCtx := null) {
		ctx		:= PegCtx(rootRule, in)
		result	:= ctx.process(rootRule)
		if (result)
			ctx.rootResult.success(actionCtx)
		return result ? ctx.rootResult.matched : null
	}
	
	Bool parse2(InStream in, Obj? actionCtx := null, Bool checked := true) {
		ctx		:= PegCtx(rootRule, in)
		result	:= ctx.process(rootRule)
		if (!result && checked)
			throw ParseErr("Could not match input with Rule: ${rootRule}")
		if (result)
			ctx.rootResult.success(actionCtx)
		return result
	}
	
	Obj? parseAll(InStream in, Obj? actionCtx := null) {
		Int? b := 69
		Bool parsed := true
		// can't do this in JS - see http://fantom.org/forum/topic/2445
//		while (parsed && (b = in.readChar) != null) { ... }
		while (parsed && b != null) {
			b = in.peekChar
			if (b != null)
				parsed = parse2(in, actionCtx, false)
		}
		return actionCtx
	}
}
