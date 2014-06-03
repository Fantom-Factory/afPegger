
class TestPropertyParsing : Test, Rules {
	
	Void testNuffin() {		
		property := "obj.list[2].map[wot].meth(judge, dredd).str().prop"
		
		fieldName	:= sequence([
			firstOf([str("_"), anyAlpha]), 
			zeroOrMore(firstOf([str("_"), anyAlphaNum]))
		]) { it.name = "fieldName" }
		basicField	:= fieldName.dup
		indexName	:= oneOrMore(anyAlphaNum) { it.name = "indexName" }
		indexField	:= sequence([fieldName.dup, str("["), indexName, str("]")])
		beanField	:= sequence([firstOf([indexField, basicField]), optional(str("."))])
		parser  	:= Parser(beanField, property.in)
		matches 	:= parser.parseAll
	}
}
