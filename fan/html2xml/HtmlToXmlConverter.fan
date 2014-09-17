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
		// TODO: 
		//	Optionally, a single "BOM" (U+FEFF) character.
		//	Any number of comments and space characters.
		//	A DOCTYPE.
		//	Any number of comments and space characters.
		//	The root element, in the form of an html element.
		//	Any number of comments and space characters.
		return element
	}
	
	Rule element() {
		firstOf([voidTag, sequence([startTag, tagContent, endTag]), err])
	}
	
	Rule voidTag() {
		sequence([ str("<"), tagName, whitespace, str("/>") ]) { it.addAction { ctx.voidTag } }
	}

	Rule startTag() {
		sequence([ str("<"), tagName, whitespace, str(">") ]) { it.action = |Match match| { ctx.startTag } }
	}

	Rule endTag() {
		sequence([ str("</"), tagName, str(">") ]) { it.action = |Match match| { ctx.endTag } }
	}
	
	Rule tagName() {
		sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars)) ]) { it.action = |Match match| { ctx.tagName = match.matched } }
	}
	
	Rule tagContent() {
		zeroOrMore(firstOf([proxy() {element}, text]))
	}
	
	Rule text() {
		oneOrMore(anyCharNotOf(['<']))
	}

	Rule whitespace() {
		zeroOrMore(anySpaceChar)
	}
	
	Rule err() {
		anyChar() { it.action = |Match match| { throw ParseErr(match.matched) } }
	}
	
	ParseCtx ctx() {
		Actor.locals["htmlToXml.ctx"]
	}
}


internal class ParseCtx {

	XElem[]			roots			:= XElem[,]	
	XElem?			openElement
	
	Str? tagName {
		set { &tagName = it.trim }
	}

	Void startTag() {
		if (openElement == null) {
			openElement = XElem(tagName)
			roots.add(openElement)
			
		} else {
			elem := XElem(tagName)
			openElement.add(elem)
			openElement = elem
		}
		
		&tagName = null
	}
	
	Void voidTag() {
		startTag
		&tagName = openElement.name
		endTag
	}

	Void endTag() {
		if (tagName != openElement.name)
			throw ParseErr("End tag </${tagName}> does not match start tag <${openElement.name}>")

		openElement = openElement.parent
	}
	
	XDoc document() {
		// TODO: check size of roots
		XDoc(roots.first)
	}
}
