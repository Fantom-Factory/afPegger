
@Js
internal class StrRule : Rule {
	private static const Regex	unicodeRegex	:= "(?:[^\\\\]|^)(\\\\u[0-9a-fA-F]{4})".toRegex
	private				 Str	str
	private				 Bool	ignoreCase

	new make(Str str, Bool ignoreCase) {
		if (str.isEmpty) throw ArgErr("String rules must match non-empty strings")
		this.str	 	= str
		this.ignoreCase	= ignoreCase
	}
	
	static Rule fromStr(Str str) {
		sClass := str
		ignore := sClass[-1] == 'i'
		if (ignore) sClass = sClass[0..<-1]

		if ((sClass[0] != '"' && sClass[-1] != '"') && (sClass[0] != '\'' && sClass[-1] != '\''))
			throw ParseErr("Invalid str class: $str")
		sClass = sClass[1..<-1]

		// de-escape unicode
		hasUnicode := true
		while (hasUnicode) {
			matcher := unicodeRegex.matcher(sClass)
			if (hasUnicode = matcher.find) {
				hex := sClass[matcher.start(1)+2..<matcher.end(1)]
				chr := Int.fromStr(hex, 16).toChar
				sClass = StrBuf(sClass.size).add(sClass).replaceRange(matcher.start(1)..<matcher.end(1), chr).toStr
			}
		}

		// de-escape chars - do the same as Fantom - https://fantom.org/doc/docLang/Literals#int
		sClass = sClass
			.replace("\\\$", "\$")
			.replace("\\b",  "\b")
			.replace("\\f",  "\f")
			.replace("\\n",  "\n")
			.replace("\\r",  "\r")
			.replace("\\t",  "\t")
			.replace("\\\"", "\"")
			.replace("\\'",  "'" )
			.replace("\\`",  "`" )
			.replace("\\\\", "\\")

		return StrRule(sClass, ignore)
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
	
	override Str expression() {
		str.toCode + (ignoreCase ? "i" : "")
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
