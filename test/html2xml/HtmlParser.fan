using xml
using concurrent

class HtmlParser {
	
	XDoc parseDocument(Str html) {
		
		parser := Parser(HtmlRules().rootRule)
		
		// TODO: parse multiple root elements, combine into 1 xml doc
		ctx := ParseCtx()
		Actor.locals["htmlToXml.ctx"] = ctx
		res := parser.parse(html.in)
		
		if (!res.passed)
			throw ParseErr("Could not parse HTML: \n${html.toCode(null)}")
		
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

		preamble						:= rules["preamble"]
		blurb							:= rules["blurb"]
		bom								:= rules["bom"]
		xml								:= rules["xml"]

		element 						:= rules["element"]

		voidElement						:= rules["voidElement"]
		voidElementName					:= rules["voidElementName"]

		selfClosingElement				:= rules["selfClosingElement"]

		rawTextElement					:= rules["rawTextElement"]
		rawTextElementTag				:= rules["rawTextElementTag"]
		rawTextElementName				:= rules["rawTextElementName"]
		rawTextElementContent			:= rules["rawTextElementContent"]
		rawText							:= rules["rawText"]

		escapableRawTextElement			:= rules["escapableRawTextElement"]
		escapableRawTextElementTag		:= rules["escapableRawTextElementTag"]
		escapableRawTextElementName		:= rules["escapableRawTextElementName"]
		escapableRawTextElementContent	:= rules["escapableRawTextElementContent"]
		escapableRawText				:= rules["escapableRawText"]

		normalElement					:= rules["normalElement"]
		normalElementContent			:= rules["normalElementContent"]
		normalElementText				:= rules["normalElementText"]
		startTag						:= rules["startTag"]
		endTag							:= rules["endTag"]
		tagName							:= rules["tagName"]
		
		attributes						:= rules["attributes"]
		emptyAttribute					:= rules["emptyAttribute"]
		unquotedAttribute				:= rules["unquotedAttribute"]
		singleAttribute					:= rules["singleAttribute"]
		doubleAttribute					:= rules["doubleAttribute"]
		attributeName					:= rules["attributeName"]
		
		characterReference				:= rules["characterReference"]
		decNumCharRef					:= rules["decNumCharRef"]
		hexNumCharRef					:= rules["hexNumCharRef"]
		
		cdata							:= rules["cdata"]
		
		comment							:= rules["comment"]

		doctype							:= rules["doctype"]
		doctypeSystemId					:= rules["doctypeSystemId"]
		doctypePublicId					:= rules["doctypePublicId"]

		whitespace						:= rules["whitespace"]

		rules["preamble"]						= sequence([bom, blurb, optional(doctype), xml, blurb, element, blurb])
		rules["blurb"]							= zeroOrMore(firstOf([oneOrMore(anySpaceChar), comment]))
		rules["bom"]							= optional(str("\uFEFF"))
		rules["xml"]							= optional(sequence([str("<?xml"), strNot("?>") ,str("?>")]))
		
		rules["element"]						= firstOf([voidElement, rawTextElement, escapableRawTextElement, normalElement, selfClosingElement])

		rules["voidElement"]					= sequence([str("<"), voidElementName, attributes,  str(">")])						.withAction { ctx.pushVoidTag }
		rules["rawTextElement"]					= sequence([rawTextElementTag, rawTextElementContent, endTag])
		rules["escapableRawTextElement"]		= sequence([escapableRawTextElementTag, escapableRawTextElementContent, endTag])
		rules["selfClosingElement"]				= sequence([str("<"), tagName, attributes, str("/>")])								.withAction { ctx.pushVoidTag }
		rules["normalElement"]					= sequence([startTag, normalElementContent, endTag])

		rules["rawTextElementTag"]				= sequence([str("<"), rawTextElementName, attributes, str(">")])					.withAction { ctx.pushStartTag }
		rules["escapableRawTextElementTag"]		= sequence([str("<"), escapableRawTextElementName, attributes, str(">")])			.withAction { ctx.pushStartTag }

		rules["startTag"]						= sequence([str("<"), tagName, attributes, str(">")])								.withAction { ctx.pushStartTag }
//		rules["endTag"]							= sequence([str("</"), EndTagRule(tagName), str(">")])								.withAction { ctx.pushEndTag }
		rules["endTag"]							= sequence([str("</"), tagName, str(">")])											.withAction { ctx.pushEndTag }

		rules["tagName"]						= tagNameRule(sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars))]))

		rules["voidElementName"]				= firstOf("area base br col embed hr img input keygen link meta param source track wbr"	.split.map { tagNameRule(str(it)) })
		rules["rawTextElementName"]				= firstOf("script style"																.split.map { tagNameRule(str(it)) })
		rules["escapableRawTextElementName"]	= firstOf("textarea title"																.split.map { tagNameRule(str(it)) })

		rules["rawTextElementContent"]			= rawText
		rules["escapableRawTextElementContent"]	= zeroOrMore(firstOf([characterReference, escapableRawText]))
		rules["normalElementContent"]			= zeroOrMore(firstOf([characterReference, comment, cdata, normalElementText, element]))
		
		rules["rawText"]						= oneOrMore(sequence([onlyIfNot(firstOf("script style"  .split.map { str("</${it}>") })), anyChar]))	.withAction { ctx.addText(it.matched) }
		rules["escapableRawText"]				= oneOrMore(sequence([onlyIfNot(firstOf("textarea title".split.map { str("</${it}>") })), anyChar]))	.withAction { ctx.addText(it.matched) }
		rules["normalElementText"]				= strNot("<")																							.withAction { ctx.addText(it.matched) }
		
		rules["attributes"]						= zeroOrMore(firstOf([anySpaceChar, doubleAttribute, singleAttribute, unquotedAttribute, emptyAttribute]))
		rules["emptyAttribute"]					= nTimes(1, attributeName).withAction { ctx.addAttrVal(ctx.attrName); ctx.setAttrValue }	// can't put the action on attributeName
		rules["unquotedAttribute"]				= sequence([attributeName, whitespace, str("="), whitespace,			oneOrMore(firstOf([characterReference, anyCharNotOf(" \t\n\r\f\"'=<>`".chars).withAction { ctx.addAttrVal(it.matched) }])).withAction { ctx.setAttrValue } ])
		rules["singleAttribute"]				= sequence([attributeName, whitespace, str("="), whitespace, str("'"),	oneOrMore(firstOf([characterReference, anyCharNotOf(			   "'".chars).withAction { ctx.addAttrVal(it.matched) }])).withAction { ctx.setAttrValue }, str("'")])
		rules["doubleAttribute"]				= sequence([attributeName, whitespace, str("="), whitespace, str("\""), oneOrMore(firstOf([characterReference, anyCharNotOf(		 	  "\"".chars).withAction { ctx.addAttrVal(it.matched) }])).withAction { ctx.setAttrValue }, str("\"")])
		rules["attributeName"]					= oneOrMore(anyCharNotOf(" \t\n\r\f\"'>/=".chars)) 																									 .withAction { ctx.setAttrName(it.matched) }
		
		rules["characterReference"]				= firstOf([decNumCharRef, hexNumCharRef])		
		rules["decNumCharRef"]					= sequence([str("&#"), oneOrMore(anyNumChar), str(";")])																	.withAction { ctx.addDecCharRef(it.matched) }
		rules["hexNumCharRef"]					= sequence([str("&#x"), oneOrMore(firstOf([anyNumChar, anyCharInRange('a'..'f'), anyCharInRange('A'..'F')])), str(";")]) 	.withAction { ctx.addHexCharRef(it.matched) }		

		rules["cdata"]							= sequence([str("<![CDATA["), strNot("]]>"), str("]]>")]).withAction { ctx.addCdata(it.matched) }

		rules["comment"]						= sequence([str("<!--"), strNot("--"), str("-->")])

		rules["doctype"]						= sequence([str("<!DOCTYPE"), oneOrMore(anySpaceChar), oneOrMore(anyAlphaNumChar).withAction { ctx.pushDoctype(it.matched) }, zeroOrMore(firstOf([doctypeSystemId, doctypePublicId])), whitespace, str(">")])
		rules["doctypeSystemId"]				= sequence([oneOrMore(anySpaceChar), str("SYSTEM"), oneOrMore(anySpaceChar), firstOf([sequence([str("\""), zeroOrMore(anyCharNotOf(['\"'])).withAction { ctx.pushSystemId(it.matched) }, str("\"")]), sequence([str("'"), zeroOrMore(anyCharNotOf(['\''])).withAction { ctx.pushSystemId(it.matched) }, str("'")])])])
		rules["doctypePublicId"]				= sequence([oneOrMore(anySpaceChar), str("PUBLIC"), oneOrMore(anySpaceChar), firstOf([sequence([str("\""), zeroOrMore(anyCharNotOf(['\"'])).withAction { ctx.pushPublicId(it.matched) }, str("\"")]), sequence([str("'"), zeroOrMore(anyCharNotOf(['\''])).withAction { ctx.pushPublicId(it.matched) }, str("'")])])])
		
		rules["whitespace"]						= zeroOrMore(anySpaceChar)
		
		return preamble
	}
	
	Rule tagNameRule(Rule rule) {
		sequence([rule.withAction { ctx.tagName = it.matched }, zeroOrMore(anySpaceChar)])
	}
	
	ParseCtx ctx() {
		// TODO: get this from pegctx
		Actor.locals["htmlToXml.ctx"]
	}
}


internal class ParseCtx {
	XElem[]			roots		:= XElem[,]	
	XElem?			openElement
	XElem			attrElem	:= XElem("attrs")
	Str?			attrName
	Str?			attrValue
	XDoc?			doc
	
	Str? tagName {
		set { &tagName = it.trim }
	}
	
	// TODO: rename all methods pushXXXX()
	
	Void pushDoctype(Str name) {
		doc = XDoc()
		doc.docType = XDocType()
		doc.docType.rootElem = name
	}

	Void pushSystemId(Str id) {
		doc.docType.systemId = id.toUri
	}
	
	Void pushPublicId(Str id) {
		doc.docType.publicId = id
	}
	
	Void pushVoidTag() {
		pushStartTag
		&tagName = openElement.name
		pushEndTag
	}

	Void pushStartTag() {
		if (openElement == null) {
			openElement = XElem(tagName)
			roots.add(openElement)
			if (doc != null)
				doc.root = openElement
		} else {
			elem := XElem(tagName)
			openElement.add(elem)
			openElement = elem
		}
		
		&tagName = null
		
		attrElem.attrs.each { openElement.add(it) }
		attrElem = XElem("attrs")
	}

	Void addText(Str text) {
		if (openElement.children.last?.nodeType == XNodeType.text)
			// for mashing lots of char refs together
			((XText) openElement.children.last).val += text
		else
			openElement.add(XText(text))
	}

	Void setAttrName(Str name) {
		attrName = name
	}

	Void addAttrVal(Str val) {
		attrValue = (attrValue ?: Str.defVal) + val
	}
	
	Void setAttrValue() {
		attrElem.addAttr(attrName, attrValue)
		attrName = null
		attrValue = null
	}

	Void addDecCharRef(Str text) {
		ref := text["&#".size..<-";".size].toInt(10).toChar
		if (attrName != null)
			addAttrVal(ref)
		else
			addText(ref)
	}
	
	Void addHexCharRef(Str text) {
		ref := text["&#x".size..<-";".size].toInt(16).toChar
		if (attrName != null)
			addAttrVal(ref)
		else
			addText(ref)
	}

	Void addCdata(Str text) {
		cdata := XText(text["<![CDATA[".size..<-"]]>".size])
		cdata.cdata = true
		openElement.add(cdata)
	}
	
	Void pushEndTag() {
		if (tagName != openElement.name)
			throw ParseErr("End tag </${tagName}> does not match start tag <${openElement.name}>")

		if (openElement.parent?.nodeType != XNodeType.doc)
			openElement = openElement.parent
	}
	
	XDoc document() {
		// TODO: check size of roots
		doc ?: XDoc(roots.first)
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
//			Actor.sleep(20ms)
//			Env.cur.err.printLine("#####################")
//			Env.cur.err.printLine(ctx.matched)
//			Actor.sleep(20ms)
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

