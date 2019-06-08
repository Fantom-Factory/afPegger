
@Js
internal class StrRule : Rule {
	private		Str				str
	private		Bool			ignoreCase
	override	Str				expression
	
	new make(Str str, Bool ignoreCase) {
		if (str.isEmpty) throw ArgErr("String rules must match non-empty strings")
		this.str	 	= str
		this.ignoreCase	= ignoreCase
		this.expression = str.toCode
	}

	override Bool doProcess(PegCtx ctx) {
		matched	:= true
		chrIdx	:= 0
		chrA	:= 0
		chrB	:= 0
		while (matched && chrIdx < str.size) {
			chrA = ctx.readChar
			chrB = str[chrIdx++]
			matched = chrA == chrB 
			if (ignoreCase && !matched)
				matched = chrA == (chrB.isLower ? chrB.upper : chrB.lower)
		}
		return matched
	}
}

@Js
internal class StrNotRule : Rule {
	private		Str		str
	private		Bool	ignoreCase
	override	Str		expression
	
	new makeFromStrFunc(Str str, Bool ignoreCase) {
		if (str.isEmpty) throw ArgErr("String rules must match non-empty strings")
		this.str		= str
		this.ignoreCase	= ignoreCase
		this.expression	= "(!${str.toCode} .)+"
	}
	
	override Bool doProcess(PegCtx ctx) {
		keepGoing	:= true
		start		:= ctx.cur
		while (keepGoing) {
			cur		:= ctx.cur
			match	:= matchStr(ctx)
			ctx.rollbackTo(cur)
			
			keepGoing = !match && !ctx.eos
			if (keepGoing)
				ctx.readChar
		}
		return ctx.cur > start
	}
	
	private Bool matchStr(PegCtx ctx) {
		matched	:= true
		chrIdx	:= 0
		chrA	:= 0
		chrB	:= 0
		while (matched && chrIdx < str.size) {
			chrA = ctx.readChar
			chrB = str[chrIdx++]
			matched = chrA == chrB 
			if (ignoreCase && !matched)
				matched = chrA == (chrB.isLower ? chrB.upper : chrB.lower)
		}
		return matched	
	}
}
