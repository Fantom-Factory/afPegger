
internal class TestRawText : HtmlParserTest {
	
	HtmlParser parser := HtmlParser()
	
	Void testRawText() {
		// plain text
		elem := parser.parseDocument("<script> Dude! </script>").root
		verifyElemEq(elem, "<script> Dude! </script>")

		// no char refs
		elem = parser.parseDocument("<script>&#160;&#xA0;</script>").root
		verifyElemEq(elem, "<script>&amp;#160;&amp;#xA0;</script>")
		verifyEq(elem.text.val, "&#160;&#xA0;")

		// no elements
		elem = parser.parseDocument("<script><wot></wot></script>").root
		verifyElemEq(elem, "<script>&lt;wot>&lt;/wot></script>")
		verifyEq(elem.text.val, "<wot></wot>")

		// no cdata
		elem = parser.parseDocument("<script><![CDATA[ nope ]]></script>").root
		verifyElemEq(elem, "<script>&lt;![CDATA[ nope ]]></script>")
		verifyEq(elem.text.val, "<![CDATA[ nope ]]>")
	}
	
	Void testEscapableRawText() {
		// plain text
		elem := parser.parseDocument("<textarea> Dude! </textarea>").root
		verifyElemEq(elem, "<textarea> Dude! </textarea>")

		// char refs
		elem = parser.parseDocument("<textarea>&#160;&#xA0;</textarea>").root
		verifyElemEq(elem, "<textarea>&#160;&#xA0;</textarea>")
		verifyEq(elem.text.val, "\u00A0\u00A0")

		// no elements
		elem = parser.parseDocument("<textarea><wot></wot></textarea>").root
		verifyElemEq(elem, "<textarea>&lt;wot>&lt;/wot></textarea>")
		verifyEq(elem.text.val, "<wot></wot>")

		// no cdata
		elem = parser.parseDocument("<textarea><![CDATA[ nope ]]></textarea>").root
		verifyElemEq(elem, "<textarea>&lt;![CDATA[ nope ]]></textarea>")
		verifyEq(elem.text.val, "<![CDATA[ nope ]]>")
	}
	

	
	// test script & style don't parse cdata and char refs and elements
	
	// test textarea only parses char refs
}
