
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

				// matcher.start() and matcher.end() are unsupported in JS for groups > 0
//				m_s := matcher.start(1)
//				m_e := matcher.end(1)

				// so adjust our logic a little to just use group 0
				m_s := matcher.start(0)
				m_e := matcher.end(0)
				if (sClass[m_s] != '\\') m_s++ 

				hex := sClass[m_s+2..<m_e]
				chr := Int.fromStr(hex, 16).toChar
				sClass = StrBuf(sClass.size).add(sClass).replaceRange(m_s..<m_e, chr).toStr
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

	override Bool doProcess(RuleCtx ctx) {
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
	
	override Str _expression() {
		str.toCode + (ignoreCase ? "i" : "")
	}
}

@Js
internal class StrNotRule : Rule {
	private		Str		str
	private		Bool	ignoreCase
	override	Str		_expression
	
	new makeFromStrFunc(Str str, Bool ignoreCase) {
		if (str.isEmpty) throw ArgErr("String rules must match non-empty strings")
		this.str		= str
		this.ignoreCase	= ignoreCase
		this._expression= "(!${str.toCode} .)+"
	}
	
	override Bool doProcess(RuleCtx ctx) {
		keepGoing	:= true
		start		:= ctx.currentPos
		while (keepGoing) {
			cur		:= ctx.currentPos
			match	:= matchStr(ctx)
			ctx.rollbackToPos(cur)
			
			keepGoing = !match && !ctx.eos
			if (keepGoing)
				ctx.readChar
		}
		return ctx.currentPos > start
	}
	
	private Bool matchStr(RuleCtx ctx) {
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
