using xml
using concurrent

class HtmlToXml {
	
	XDoc parseDocument(Str html) {
		
		parser := Parser(HtmltoXmlRules().rootRule)
		
		// TODO: parse multiple root elements, combine into 1 xml doc
		ctx := ParseCtx()
		Actor.locals["htmlToXml.ctx"] = ctx
		parser.parse(html.in)
		
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
		
		element 						:= rules["element"]

		voidElement						:= rules["voidElement"]
		voidElementName					:= rules["voidElementName"]

		rawTextElement					:= rules["rawTextElement"]
		rawTextElementTag				:= rules["rawTextElementTag"]
		rawTextElementName				:= rules["rawTextElementName"]
		rawTextElementContent			:= rules["rawTextElementContent"]

		escapableRawTextElement			:= rules["escapableRawTextElement"]
		escapableRawTextElementTag		:= rules["escapableRawTextElementTag"]
		escapableRawTextElementName		:= rules["escapableRawTextElementName"]
		escapableRawTextElementContent	:= rules["escapableRawTextElementContent"]

		selfClosingElement				:= rules["selfClosingElement"]
		normalElement					:= rules["normalElement"]
		startTag						:= rules["startTag"]
		endTag							:= rules["endTag"]
		tagName							:= rules["tagName"]
		normalElementContent			:= rules["normalElementContent"]
		
		attributes						:= rules["attributes"]
		characterEntity					:= rules["characterEntity"]
		
		text							:= rules["text"]
		rawText							:= rules["rawText"]
		whitespace						:= rules["whitespace"]

		rules["element"]						= firstOf([voidElement, rawTextElement, escapableRawTextElement, selfClosingElement, normalElement]) { it.name = "Element" }
		rules["element"]						= firstOf([voidElement, selfClosingElement, normalElement]) { it.name = "Element" }

		rules["voidElement"]					= sequence([str("<"), voidElementName, attributes,  str(">")])						{ it.name = "Void Element";						it.action = |Result result| { ctx.voidTag	} }
		rules["rawTextElement"]					= sequence([rawTextElementTag, rawTextElementContent, endTag])						{ it.name = "Raw Text Element" }
		rules["escapableRawTextElement"]		= sequence([escapableRawTextElementTag, escapableRawTextElementContent, endTag])	{ it.name = "Escapable Raw Text Element" }
		rules["selfClosingElement"]				= sequence([str("<"), tagName, attributes, str("/>")])								{ it.name = "Self Closing Element"; 			it.action = |Result result| { ctx.voidTag	} }
		rules["normalElement"]					= sequence([startTag, normalElementContent, endTag]) 								{ it.name = "Normal Element" }

		rules["rawTextElementTag"]				= sequence([str("<"), rawTextElementName, attributes, str( ">")])					{ it.name = "Raw Text Element Tag"; 			it.action = |Result result| { ctx.startTag	} }
		rules["escapableRawTextElementTag"]		= sequence([str("<"), escapableRawTextElementName, attributes, str( ">")])			{ it.name = "Escapable Raw Text Element Tag";	it.action = |Result result| { ctx.startTag	} }

		rules["startTag"]						= sequence([str("<"), tagName, attributes, str( ">")])								{ it.name = "Start Tag";						it.action = |Result result| { ctx.startTag	} }
		rules["endTag"]							= sequence([str("</"), tagName, str(">")])											{ it.name = "End Tag";							it.action = |Result result| { ctx.endTag	} }

		rules["tagName"]						= tagNameRule(sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars))]), "Tag Name")

		rules["voidElementName"]				= firstOf("area base br col embed hr img input keygen link meta param source track wbr"	.split.map { tagNameRule(str(it), "Void Element Name") })
		rules["rawTextElementName"]				= firstOf("script style"																.split.map { tagNameRule(str(it), "Raw Text Element Name") })
		rules["escapableRawTextElementName"]	= firstOf("textarea title"																.split.map { tagNameRule(str(it), "Escapable Raw Text Element Name") })

		rules["rawTextElementContent"]			= rawText
		rules["escapableRawTextElementContent"]	= zeroOrMore(firstOf([text, characterEntity]))						{ it.name = "Escapable Raw Text Element Content" }
		rules["normalElementContent"]			= zeroOrMore(firstOf([text, characterEntity, element]))				{ it.name = "Normal Element Content" }
		
		rules["attributes"]						= todo(true)
		
		rules["characterEntity"]				= todo(false)
		
		rules["text"]							= oneOrMore(anyCharNotOf("<&".chars))	{ it.name = "Text"			}
		rules["rawText"]						= oneOrMore(strNot("</"))				{ it.name = "Raw Text"		}
		rules["whitespace"]						= zeroOrMore(anySpaceChar)				{ it.name = "Whitespace"	}
		
		return element
	}
	
	Rule tagNameRule(Rule rule, Str name) {
		sequence([rule { it.name = name; it.action = |Result result| { ctx.tagName = result.matched } }, zeroOrMore(anySpaceChar) { it.name = "Whitespace" }])
	}
	
	ParseCtx ctx() {
		// TODO: get this from pegctx
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
