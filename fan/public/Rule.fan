
** (Advanced)  
** Models a PEG Rule.
** 
** Rules are commonly created by using methods from the `Rules` mixin, but may be parsed from patterns.
** 
** `Rule` is not intended to be created or subclassed by the user. 
@Js
abstract class Rule {
	
	** Internal ctor.
	** The 'abstract doProcess()' is internal, so it's not like anyone can write their own Rules.
	internal new make() { }
	
	** Creates a rule by parsing the given pattern:
	** 
	**   syntax: fantom 
	**   Rule.fromPattern("[abc] / [xyz]")
	** 
	** See `Peg.parseRule`
	static new parseRule(Str pattern) {
		PegGrammar().parseRule(pattern)
	}

	** The name of this rule. Only rules with names appear in debug output.
	** Should be legal Fantom identifier (think variable names!).
	Str? name {
		set {
			if (!it.chars.first.isAlpha || it.chars.any { !it.isAlphaNum && it != '_' })
				throw ArgErr("Name must be a valid Fantom identifier: $it")
			&name = it
		}
	}
	
	** Disable debugging of this rule if it gets to noisy.
	Bool debug			:= true

	** Not all rules are useful in the parsed AST. 
	Bool useInResult	:= true
	
	** Action to be performed upon successful completion of this rule.
	virtual |Str matched|?	action

	** Override to implement Rule logic.
	abstract internal Bool doProcess(PegCtx ctx)
	
	** Returns the PEG expression for this rule. Example:
	** 
	**   [a-zA-Z0-9]
	abstract Str expression()

	** Returns the PEG definition for this rule. Example:
	** 
	**   alphaNum <- [a-zA-Z0-9]
	Str definition() {
		((name == null) ? "" : "${name} <- ") + expression
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
	internal Str _dis(Bool inner := false) {
		inner && name == null && (this is SequenceRule || this is FirstOfRule)
			? "(" + expression + ")"
			: (name ?: expression)
	}

	@NoDoc
	override Str toStr() { _dis }  
}
