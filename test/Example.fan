using xml
//using afPegger

@Js
class Example {
	Void main() {
		Parser#.pod.log.level = LogLevel.debug
		elem := TagParser().parseTags("<html><title>Pegger Example</title><body>Parsing is Easy!</body></html>")
		
		echo(elem.writeToStr) 	// -->
								// <html>
								// <title>Pegger Example</title>
								// <body>Parsing is Easy!</body>
								// </html>
		
		elem = TagParser().parseTags("<html><title>Pegger Example</oops></html>")
		// --> sys::ParseErr: End tag </oops> does not match start tag <title>
	}
}

//internal class Example : Rules {	
//	Void main() {
//		//  add actions to successful matches
//		name  := oneOrMore(anyAlphaChar).withAction |Str match| { echo(match)  }
//		
//		// build up rules from the Rules mixin
//		rules := sequence([char('<'), name, char('>')])
//		
//		// run the parser to run your actions
//		Parser(rules).parse("<HelloMum>".in)	// --> HelloMum 
//	}
//}

@Js
internal class TagParser : Rules {
	XElem?	root
	XElem?	elem
	
	XElem parseTags(Str tags) {
		Parser(rules).parse(tags.in)
		return root
	}
	
	Rule rules() {
		// use 'NamedRules' to define rules in any order and to avoid recursion 
		rules 		:= NamedRules()
		element		:= rules["element"]
		startTag	:= rules["startTag"]
		endTag		:= rules["endTag"]
		text		:= rules["text"]
		
		rules["element"]	= sequence([startTag, zeroOrMore(firstOf([element, text])), endTag])		
		rules["startTag"]	= sequence([char('<'), oneOrMore(anyAlphaChar), char('>')])	.withAction { pushStartTag(it) }
		rules["endTag"]		= sequence([str("</"), oneOrMore(anyAlphaChar), char('>')])	.withAction { pushEndTag(it) }
		rules["text"]		= oneOrMore(anyCharNot('<'))								.withAction { pushText(it) }

		return element
	}
	
	Void pushStartTag(Str tagName) {
		child := XElem(tagName[1..<-1])
		if (root == null)
			root = child
		else
			elem.add(child)
		elem = child
	}

	Void pushEndTag(Str tagName) {
		if (tagName[2..<-1] != elem.name)
			throw ParseErr("End tag ${tagName} does not match start tag <${elem.name}>")
		elem = elem.parent
	}

	Void pushText(Str text) {
		elem.add(XText(text))
	}
}
