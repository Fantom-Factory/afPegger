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
	
	NamedRules rules := NamedRules()

	Rule rootRule() {
		// TODO: 
		//	Optionally, a single "BOM" (U+FEFF) character.
		//	Any number of comments and space characters.
		//	A DOCTYPE.
		//	Any number of comments and space characters.
		//	The root element, in the form of an html element.
		//	Any number of comments and space characters.
		
		
		element 	:= rules["element"]		
		voidTag		:= rules["voidTag"]
		startTag	:= rules["startTag"]
		endTag		:= rules["endTag"]
		tagName		:= rules["tagName"]
		tagContent	:= rules["tagContent"]
		text		:= rules["text"]
		whitespace	:= rules["whitespace"]

		rules["element"]	= firstOf([voidTag, sequence([startTag, tagContent, endTag])])			{ it.name = "Element" 		}
		rules["voidTag"]	= sequence([ str("<"), tagName, whitespace, str("/>") ])				{ it.name = "Void Tag"		; it.action = |Result result| { ctx.voidTag } }
		rules["startTag"]	= sequence([ str("<"), tagName, whitespace, str(">") ])					{ it.name = "Start Tag"		; it.action = |Result result| { ctx.startTag } }
		rules["endTag"]		= sequence([ str("</"), tagName, str(">") ])							{ it.name = "End Tag"		; it.action = |Result result| { ctx.endTag } }
		rules["tagName"]	= sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars))]) { it.name = "Tag Name"		; it.action = |Result result| { ctx.tagName = result.matched } }
		rules["tagContent"]	= zeroOrMore(firstOf([element, text]))									{ it.name = "Tag Content"	}
		rules["text"]		= oneOrMore(anyCharNotOf(['<']))										{ it.name = "Text"			}
		rules["whitespace"]	= zeroOrMore(anySpaceChar)												{ it.name = "Whitespace"	}
		
		return element
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
