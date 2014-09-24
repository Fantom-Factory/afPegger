
internal class TestRawText : HtmlParserTest {
	
	HtmlParser parser := HtmlParser()
	
	Void testRawText() {
		// plain text
//		elem := parser.parseDocument("<script> Dude! </script>").root
//		verifyElemEq(elem, "<script> Dude! </script>")

		// no elements
		elem := parser.parseDocument("<script><wot></wot></script>").root
		verifyElemEq(elem, "<script><wot></wot></script>")
		verifyEq(elem.children.size, 0)
	}
	

	
	// test script & style don't parse cdata and char refs and elements
	
	// test textarea only parses char refs
}
