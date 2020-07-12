
** (Advanced)  
** Models a PEG Rule.
** 
** Rules are commonly created by using methods from the `Rules` mixin, but may be parsed from string patterns.
** 
** `Rule` *may* sub-classed to create your own custom rules. 
@Js
abstract class Rule {
	
	** Creates a rule by parsing the given pattern:
	** 
	**   syntax: fantom 
	**   Rule.fromPattern("[abc] / [xyz]")
	** 
	** See `Peg.parseRule`
	static new parseRule(Str pattern) {
		PegGrammar().parseRule(pattern)
	}

	** The name of this rule definition.
	** 
	**   name <- foobar foobar
	** 
	** Only rules with names (or labels) appear in debug output and the output tree, unless explicitly disabled.
	** 
	** Should be a legal Fantom identifier (think variable names!).
	virtual Str? name {
		set {
			// allow names to be programmatically re-set
			if (!it.chars.first.isAlpha || it.chars.any { !it.isAlphaNum && it != '_' && it != '-' })
				throw ArgErr("Name must be a valid Fantom identifier: $it")
			&name = it
		}
	}
	
	** A label for this rule.
	** 
	**   someRule <- label:foobar foobar
	** 
	** Note the same rule definition may have multiple / different labels when used in different parts of PEG grammar.  
	** 
	** Only rules with labels (or names) appear in debug output and the output tree, unless explicitly disabled.
	** 
	** Should be a legal Fantom identifier (think variable names!).
	virtual Str? label {
		set {
			// allow labels to be programmatically re-set
			if (!it.chars.first.isAlpha || it.chars.any { !it.isAlphaNum && it != '_' && it != '-' })
				throw ArgErr("Label must be a valid Fantom identifier: $it")
			&label = it
		}
	}
	
	** Disable debugging of this rule if it gets too noisy.
	virtual Bool debug			:= true

	** Not all rules are useful in the parsed AST. 
	virtual Bool useInResult	:= true

	** Override to implement Rule logic.
	@NoDoc
	abstract Bool doProcess(RuleCtx ctx)
	
	** Returns the PEG expression for this rule. Example:
	** 
	**   [a-zA-Z0-9]
	abstract Str expression()

	** Returns the PEG definition for this rule. Example:
	** 
	**   alphaNum <- [a-zA-Z0-9]
	Str definition() {
		if (name == null) return expression
		ex := name
		if (!useInResult)	ex = "-" + ex
		if (!debug)			ex = ex + "-"
		return "${ex} <- ${expression}"
	}

	** A helpful builder method for setting the name.
	** 
	**   name <- foobar foobar
	** 
	** Only rules with names (or labels) appear in debug output and the output tree, unless explicitly disabled.
	** 
	** Should be a legal Fantom identifier (think variable names!).
	This withName(Str? name) {
		this.name = name
		return this
	}

	** A helpful builder method for setting the label.
	** 
	**   someRule <- label:foobar foobar
	** 
	** Note the same rule definition may have multiple / different labels when used in different parts of PEG grammar.  
	** 
	** Only rules with labels (or names) appear in debug output and the output tree.
	** 
	** Should be a legal Fantom identifier (think variable names!).
	This withLabel(Str? label) {
		this.label = label
		return this
	}

	** A helpful builder method for turning debug off.
	** 
	** In PEG grammar, rules are excluded from debug by add a hyphen suffix to the declaration.
	** 
	**   noDebugRule-  = foobar foobar
	This debugOff() {
		this.debug = false
		return this
	}
	
	** A helpful builder method for removing this rule from tree results.
	** 
	** In PEG grammar, rules are excluded from results by add a hyphen prefix to the declaration.
	** 
	**   -excludedRule  = foobar foobar
	This excludeFromResults() {
		this.useInResult = false
		return this
	}
	
	** Matches this rule against the given string.
	** 
	** See `Peg.match`
	Match? match(Str str) {
		Peg(str, this).match
	}
	
	@NoDoc
	virtual Str typeName() {
		// if converting doProcess() to processFn then THIS method will need to be converted to another field 
		name := typeof.name.decapitalize
		return name.endsWith("Rule") ? name[0..<-4] : name
	}

	@Operator @NoDoc
	virtual This add(Rule rule) {
		throw Err("${typeof.qname} does not support add()")
	}
	
	@NoDoc
	internal Str _dis(Bool inner := false) {
		dis := inner && name == null && (this is SequenceRule || this is FirstOfRule)
			? "(" + expression + ")"
			: (name ?: expression)
		return _labelDis + dis
	}

	@NoDoc
	internal Str _labelDis() {
		label == null ? "" : label + ":"
	}
	
	@NoDoc
	override Str toStr() { _dis(false) }  
}
