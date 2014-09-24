using xml
using concurrent

class HtmlParser {
	
	XDoc parseDocument(Str html) {
		
		parser := Parser(HtmlRules().rootRule)
		
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

internal class HtmlRules : Rules {
	
	Rule rootRule() {
		rules := NamedRules()

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

		rules["element"]						= firstOf([voidElement, rawTextElement, escapableRawTextElement, selfClosingElement, normalElement])
//		rules["element"]						= firstOf([voidElement, selfClosingElement, normalElement])

		rules["voidElement"]					= sequence([str("<"), voidElementName, attributes,  str(">")])						{ it.action = |Result result| { ctx.voidTag		} }
		rules["rawTextElement"]					= sequence([rawTextElementTag, rawTextElementContent, endTag])
		rules["escapableRawTextElement"]		= sequence([escapableRawTextElementTag, escapableRawTextElementContent, endTag])
		rules["selfClosingElement"]				= sequence([str("<"), tagName, attributes, str("/>")])								{ it.action = |Result result| { ctx.voidTag		} }
		rules["normalElement"]					= sequence([startTag, normalElementContent, endTag])

		rules["rawTextElementTag"]				= sequence([str("<"), rawTextElementName, attributes, str(">")])					{ it.action = |Result result| { ctx.startTag	} }
		rules["escapableRawTextElementTag"]		= sequence([str("<"), escapableRawTextElementName, attributes, str(">")])			{ it.action = |Result result| { ctx.startTag	} }

		rules["startTag"]						= sequence([str("<"), tagName, attributes, str(">")])								{ it.action = |Result result| { ctx.startTag	} }
		rules["endTag"]							= sequence([str("</"), EndTagRule(tagName), str(">")])								{ it.action = |Result result| { ctx.endTag		} }

		rules["tagName"]						= tagNameRule(sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars))]))

		rules["voidElementName"]				= firstOf("area base br col embed hr img input keygen link meta param source track wbr"	.split.map { tagNameRule(str(it)) })
		rules["rawTextElementName"]				= firstOf("script style"																.split.map { tagNameRule(str(it)) })
		rules["escapableRawTextElementName"]	= firstOf("textarea title"																.split.map { tagNameRule(str(it)) })

		rules["rawTextElementContent"]			= rawText
		rules["escapableRawTextElementContent"]	= zeroOrMore(firstOf([text, characterEntity]))
		rules["normalElementContent"]			= zeroOrMore(firstOf([text, characterEntity, element]))
		
		rules["attributes"]						= todo(true)
		
		rules["characterEntity"]				= todo(false)
		
		rules["text"]							= oneOrMore(anyCharNotOf("<&".chars))	{ it.action = |Result result| { ctx.addText(result.matched)	} }
		rules["rawText"]						= oneOrMore(strNot("</"))				{ it.action = |Result result| { ctx.addText(result.matched)	} }
		rules["whitespace"]						= zeroOrMore(anySpaceChar)
		
		return element
	}
	
	Rule tagNameRule(Rule rule) {
		sequence([rule { it.action = |Result result| { ctx.tagName = result.matched } }, zeroOrMore(anySpaceChar)])
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
	
	Void voidTag() {
		startTag
		&tagName = openElement.name
		endTag
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

	Void addText(Str text) {
		openElement.add(XText(text))
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

internal class EndTagRule : Rule {
	private Rule	rule
	
	new make(Rule rule) {
		this.rule = rule
	}
	
	override Void doProcess(PegCtx ctx) {
		passed := ctx.process(rule)
		
		if (passed) {
			Actor.sleep(20ms)
			Env.cur.err.printLine("#####################")
			Env.cur.err.printLine(ctx.matched)
			Actor.sleep(20ms)
			//End tag </wot> does not match start tag <script>
		}
		
		ctx.pass(passed)
	}

	override Str expression() {
		rule.expression
	}
	
	ParseCtx ctx() {
		// TODO: get this from pegctx
		Actor.locals["htmlToXml.ctx"]
	}
}

