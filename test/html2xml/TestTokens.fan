using xml

** http://www.w3.org/html/wg/drafts/html/CR/syntax.html
class TestTokens : Test {
	
	HtmlToXml parser := HtmlToXml()
	
	Void testInvalidTag() {
		verifyErrMsg(ParseErr#, "Invalid tag: <1") {
			parser.parseDocument("<1h>")
		}
	}

	Void testBogusCommentTag() {
		verifyErrMsg(ParseErr#, "Bogus comment tag: <?") {
			parser.parseDocument("<? wotever >")
		}
	}

	Void testValidSimpleTag() {
		doc := parser.parseDocument("<html>")
		verifyEq(doc.root.name, "html")
		verifyEq(doc.root.attrs.size, 0)
		verifyEq(doc.root.children.size, 0)
	}

	
	Void verifyErrMsg(Type errType, Str errMsg, |Test| c) {
		try {
			c.call(this)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				verifyEq(errType, e.typeof)
			verifyEq(errMsg, e.msg)
			return
		}
		fail("$errType not thrown")
	}
}
