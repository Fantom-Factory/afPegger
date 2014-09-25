
** A PEG Rule.
abstract class Rule {
	** The name of this rule. Should be legal Fantom identifier (think variable names!).
	Str? 		name
	
	** The action to be performed upon successful completion of this rule.
	virtual |Str|?	action

	** Override to implement Rule logic.
	abstract protected Bool doProcess(PegCtx ctx)
	
	** Returns the PEG expression for this rule. Example:
	** 
	**   [a-zA-Z0-9]
	abstract Str expression()

	** Returns the PEG definition for this rule. Example:
	** 
	**   alphaNum <- [a-zA-Z0-9]
	Str definition() {
		((name == null) ? Str.defVal : "${name} <- ") + expression		
	}
	
	** A helpful builder method for setting the action.
	This withAction(|Str|? action) {
		this.action = action
		return this
	}

	** A helpful builder method for setting the name.
	This withName(Str name) {
		this.name = name
		return this
	}
	
	@Operator @NoDoc
	virtual This add(Rule rule) {
		throw Err("${typeof.qname} does not support add()")
	}
	
	@NoDoc
	override Str toStr() {
		name ?: expression
	}
	
	** Wraps the given rule's expression in brackets only when required to remove ambiguity.
	** 
	** Use when deriving your own Rule expressions.  
	@NoDoc	// needs a lot more work - needs to looks for spaces NOT in [ ] and not ((double wrap)) existing brackets
	static protected Str wrapRuleName(Rule rule) {
		desc := rule.name ?: rule.expression
		if (Regex<|[^\[]\s+[^\]]|>.matcher(desc).find) {
			if (desc.startsWith("(") && desc.endsWith(")")) {
				if (desc.index("(", 1) > desc.index(")", 1))
					desc = "(${desc})" 
			} else
				desc = "(${desc})" 			
		}
		return desc
	}
}
