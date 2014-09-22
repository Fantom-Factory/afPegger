using xml

** http://www.w3.org/html/wg/drafts/html/CR/syntax.html
class TestTokens : Test {
	
	HtmlToXml parser := HtmlToXml()

	Void testValidSimpleTag() {
		elem := parser.parseDocument("<html></html>").root
		verifyEq(elem.name, "html")
		verifyEq(elem.attrs.size, 0)
		verifyEq(elem.children.size, 0)

		elem = parser.parseDocument("<html  ></html>").root
		verifyEq(elem.name, "html")
		verifyEq(elem.attrs.size, 0)
		verifyEq(elem.children.size, 0)

		elem = parser.parseDocument("<html/>").root
		verifyEq(elem.name, "html")
		verifyEq(elem.attrs.size, 0)
		verifyEq(elem.children.size, 0)

		elem = parser.parseDocument("<html  />").root
		verifyEq(elem.name, "html")
		verifyEq(elem.attrs.size, 0)
		verifyEq(elem.children.size, 0)
	}
	
	Void testValidNestedTag() {
		elem := parser.parseDocument("<html><head></head></html>").root
		verifyElemEq(elem, "<html><head/></html>")
		
		elem = parser.parseDocument("<html><head  ></head></html>").root
		verifyElemEq(elem, "<html><head/></html>")
		
		elem = parser.parseDocument("<html><head/></html>").root
		verifyElemEq(elem, "<html><head/></html>")
		
		elem = parser.parseDocument("<html><head  /></html>").root
		verifyElemEq(elem, "<html><head/></html>")
	}

	Void testValidSiblingTags() {
		elem := parser.parseDocument("<html><head/><body/></html>").root
		verifyElemEq(elem, "<html><head/><body/></html>")
		
		elem = parser.parseDocument("<html><head><title/></head></html>").root
		verifyElemEq(elem, "<html><head><title/></head></html>")
		
		elem = parser.parseDocument("<html><head/><body><div/></body></html>").root
		verifyElemEq(elem, "<html><head/><body><div/></body></html>")
	}
	
	Void testVoidTags() {
		elem := parser.parseDocument("<area>").root
		verifyElemEq(elem, "<area>")
		
		elem = parser.parseDocument("<html><meta  ><img  ></html>").root
		verifyElemEq(elem, "<html><meta/><img/></html>")
	}



	Void verifyElemEq(XElem elem, Str xml) {
		act := elem.writeToStr.replace("\n", "")
		exp := XParser(xml.in).parseDoc.root.writeToStr.replace("\n", "")
		verifyEq(act, exp)
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
