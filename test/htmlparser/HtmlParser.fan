using xml
using concurrent

// an old version of HtmlParser used for testing
@Js
internal class HtmlParser {
	
	private Rule htmlRules := HtmlRules().rootRule
	
	XDoc parseDocument(Str html) {
		ctx := ParseCtx()
		Actor.locals["htmlToXml.ctx"] = ctx
			
		res := Peg(html, htmlRules).match
		
		if (res == null)
			throw ParseErr("Could not parse HTML: \n${html.toCode(null)}")
		
		res.dump
		
		return ctx.document
	}

	XElem parseFragment(Str html, XElem? context) {
		// see 8.4
		XElem("dude")
	}
}

@Js
internal class HtmlRules : Rules {
	
	// updates:
	// - preable -> dom
	// - tagName -> useInResult = false
	Rule rootRule() {
		rules := NamedRules()

		dom								:= rules["dom"]
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

		rules["dom"]							= sequence([bom, blurb, optional(doctype), xml, blurb, element, blurb])
		rules["blurb"]							= zeroOrMore(firstOf([oneOrMore(anySpaceChar), comment]))
		rules["bom"]							= optional(str("\uFEFF"))
		rules["xml"]							= optional(sequence([str("<?xml"), strNot("?>") ,str("?>")]))
		
		rules["element"]						= firstOf([voidElement, rawTextElement, escapableRawTextElement, normalElement, selfClosingElement])

		rules["voidElement"]					= sequence([char('<'), voidElementName, attributes,  char('>')])					.withAction { ctx.pushVoidTag }
		rules["rawTextElement"]					= sequence([rawTextElementTag, rawTextElementContent, endTag])
		rules["escapableRawTextElement"]		= sequence([escapableRawTextElementTag, escapableRawTextElementContent, endTag])
		rules["selfClosingElement"]				= sequence([char('<'), tagName, attributes, str("/>")])								.withAction { ctx.pushVoidTag }
		rules["normalElement"]					= sequence([startTag, normalElementContent, endTag])

		rules["rawTextElementTag"]				= sequence([char('<'), rawTextElementName, attributes, char('>')])					.withAction { ctx.pushStartTag }
		rules["escapableRawTextElementTag"]		= sequence([char('<'), escapableRawTextElementName, attributes, char('>')])			.withAction { ctx.pushStartTag }

		rules["startTag"]						= sequence([char('<'), tagName, attributes, char('>')])								.withAction { ctx.pushStartTag }
//		rules["endTag"]							= sequence([str("</"), EndTagRule(tagName), str(">")])								.withAction { ctx.pushEndTag }
		rules["endTag"]							= sequence([str("</"), tagName, char('>')])											.withAction { ctx.pushEndTag }

		rules["tagName"]						= tagNameRule(sequence([anyAlphaChar, zeroOrMore(anyCharNotOf("\t\n\f />".chars))]))

		rules["voidElementName"]				= firstOf("area base br col embed hr img input keygen link meta param source track wbr"	.split.map { tagNameRule(str(it)) })
		rules["rawTextElementName"]				= firstOf("script style"																.split.map { tagNameRule(str(it)) })
		rules["escapableRawTextElementName"]	= firstOf("textarea title"																.split.map { tagNameRule(str(it)) })

		rules["rawTextElementContent"]			= rawText
		rules["escapableRawTextElementContent"]	= zeroOrMore(firstOf([characterReference, escapableRawText]))
		rules["normalElementContent"]			= zeroOrMore(firstOf([characterReference, comment, cdata, normalElementText, element]))
		
		rules["rawText"]						= oneOrMore(sequence([onlyIfNot(firstOf("script style"  .split.map { str("</${it}>") })), anyChar]))	.withAction { ctx.addText(it) }
		rules["escapableRawText"]				= oneOrMore(sequence([onlyIfNot(firstOf("textarea title".split.map { str("</${it}>") })), anyChar]))	.withAction { ctx.addText(it) }
//		rules["normalElementText"]				= strNot("<")																							.withAction { ctx.addText(it) }
		rules["normalElementText"]				= oneOrMore(anyCharNot('<'))																			.withAction { ctx.addText(it) }
		
		rules["attributes"]						= zeroOrMore(firstOf([anySpaceChar, doubleAttribute, singleAttribute, unquotedAttribute, emptyAttribute]))
		rules["emptyAttribute"]					= nTimes(1, attributeName).withAction { ctx.addAttrVal(ctx.attrName); ctx.setAttrValue }	// can't put the action on attributeName
		rules["unquotedAttribute"]				= sequence([attributeName, whitespace, char('='), whitespace,			oneOrMore(firstOf([characterReference, anyCharNotOf(" \t\n\r\f\"'=<>`".chars).withAction { ctx.addAttrVal(it) }])).withAction { ctx.setAttrValue } ])
		rules["singleAttribute"]				= sequence([attributeName, whitespace, char('='), whitespace, char('\''),oneOrMore(firstOf([characterReference, anyCharNotOf(			   "'".chars).withAction { ctx.addAttrVal(it) }])).withAction { ctx.setAttrValue }, char('\'')])
		rules["doubleAttribute"]				= sequence([attributeName, whitespace, char('='), whitespace, char('"'),  oneOrMore(firstOf([characterReference, anyCharNotOf(		 	  "\"".chars).withAction { ctx.addAttrVal(it) }])).withAction { ctx.setAttrValue }, char('"')])
		rules["attributeName"]					= oneOrMore(anyCharNotOf(" \t\n\r\f\"'>/=".chars)) 																									 .withAction { ctx.setAttrName(it) }
		
		rules["characterReference"]				= firstOf([decNumCharRef, hexNumCharRef])		
		rules["decNumCharRef"]					= sequence([str("&#"), oneOrMore(anyNumChar), char(';')])																	.withAction { ctx.addDecCharRef(it) }
		rules["hexNumCharRef"]					= sequence([str("&#x"), oneOrMore(firstOf([anyNumChar, anyCharInRange('a'..'f'), anyCharInRange('A'..'F')])), char(';')]) 	.withAction { ctx.addHexCharRef(it) }		

		rules["cdata"]							= sequence([str("<![CDATA["), strNot("]]>"), str("]]>")]).withAction { ctx.addCdata(it) }

		rules["comment"]						= sequence([str("<!--"), strNot("--"), str("-->")])

		rules["doctype"]						= sequence([str("<!DOCTYPE"), oneOrMore(anySpaceChar), oneOrMore(anyAlphaNumChar).withAction { ctx.pushDoctype(it) }, zeroOrMore(firstOf([doctypeSystemId, doctypePublicId])), whitespace, str(">")])
		rules["doctypeSystemId"]				= sequence([oneOrMore(anySpaceChar), str("SYSTEM"), oneOrMore(anySpaceChar), firstOf([sequence([char('"'), zeroOrMore(anyCharNot('"')).withAction { ctx.pushSystemId(it) }, char('"')]), sequence([char('\''), zeroOrMore(anyCharNot('\'')).withAction { ctx.pushSystemId(it) }, char('\'')])])])
		rules["doctypePublicId"]				= sequence([oneOrMore(anySpaceChar), str("PUBLIC"), oneOrMore(anySpaceChar), firstOf([sequence([char('"'), zeroOrMore(anyCharNot('"')).withAction { ctx.pushPublicId(it) }, char('"')]), sequence([char('\''), zeroOrMore(anyCharNot('\'')).withAction { ctx.pushPublicId(it) }, char('\'')])])])
		
		rules["whitespace"]						= zeroOrMore(anySpaceChar)
		
		return dom
	}
	
	Rule tagNameRule(Rule rule) {
		sequence([rule.withAction { ctx.tagName = it }, zeroOrMore(anySpaceChar)]) { it.useInResult = false }
	}
	
	ParseCtx ctx() {
		Actor.locals["htmlToXml.ctx"]
	}
}


@Js
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
		doc ?: XDoc(roots.first)
	}
}

