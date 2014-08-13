using xml
using concurrent

class HtmlToXml {
	
	XDoc parseDocument(Str html) {
		
		parser := Parser(HtmltoXmlRules().rootRule, html.in)
		
		// TODO: parse multiple root elements, combine into 1 xml doc
		ctx := ParseCtx()
		Actor.locals["htmlToXml.ctx"] = ctx
		parser.parse
		
		return ctx.document
	}

	XElem parseFragment(Str html, XElem? context) {
		// see 8.4
		XElem("dude")
	}

}

internal class HtmltoXmlRules : Rules {
	
	Rule rootRule() {
		return dataState
		
//	Optionally, a single "BOM" (U+FEFF) character.
//	Any number of comments and space characters.
//	A DOCTYPE.
//	Any number of comments and space characters.
//	The root element, in the form of an html element.
//	Any number of comments and space characters.

	}
	
	Rule dataState() {
		firstOf([charRef, tag, voidTag, endTag, markupDeclaration, bogusComment, invalidTag, anyChar() { it.action = |Match match| { err(match.matched) } }])
	}
	
	Rule charRef(Int? allowedChar := null) {
		todo
	}
	
	Rule tag() {
		sequence([ str("<"), tagName, whitespace, str(">") ]) { it.action = |Match match| { ctx.startTag } }
	}

	Rule voidTag() {
		sequence([ str("<"), tagName, whitespace, str("/>") ]) { it.action = |Match match| { ctx.voidTag } }
	}

	Rule endTag() {
		sequence([ str("</"), tagName, str(">") ]) { it.action = |Match match| { ctx.endTag } }
	}
	
	Rule markupDeclaration() {
		todo
	}

	Rule bogusComment() {
		// ALT: 8.2.4.44 Bogus comment state
		str("<?") { it.action = |Match match| { err("Bogus comment tag: ${match.matched}") } }
	}
	
	Rule invalidTag() {
		sequence([str("<"), anyChar]) { it.action = |Match match| { err("Invalid tag: ${match.matched}") } }
	}
	
	Rule tagName() {
		sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars)) ]) { it.action = |Match match| { ctx.tagName = match.matched } }
	}
	
	Rule ampChar() {
		str("&") { it.action = |Match match| { } }
	}

	Rule gtChar() {
		str("<") { it.action = |Match match| { } }
	}

	Rule nullChar() {
		// ALT: Emit the current input character as a character token.
		str(Str.fromChars([0])) { it.action = |Match match| { err("NULL char") } }
	}

	Rule whitespace() {
		zeroOrMore(anySpaceChar)
	}
	
	ParseCtx ctx() {
		Actor.locals["htmlToXml.ctx"]
	}
	
	Void err(Str msg) {
		throw ParseErr(msg)
	}
}


internal class ParseCtx {
	
	TokenState		tokenState		:= TokenState.data
	Int[]			tokens			:= Int[,]
	
	Bool 			last			:= false
	InsertionMode	insertionMode	:= InsertionMode.initial
	XElem[]			openElements	:= XElem[,]
	
	XElem?			doc
	
	XElem? node() {
		openElements.last
	}
	
	Void addChar(Str chr) {
		
	}
	
	Str? tagName

	Void startTag() {
		elem := XElem(tagName)
		if (doc == null)
			doc = elem
		tagName = null
	}
	
	Void voidTag() {
		startTag
		endTag
	}

	Void endTag() {}
	
	XDoc document() {
		XDoc(doc)
	}
}

internal enum class TokenState {
	data,
	charRefInData,
	tagOpen
	
	
}