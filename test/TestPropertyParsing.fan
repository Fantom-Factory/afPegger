
class TestPropertyParsing : Test, Rules {
	
	Void testNuffin() {		
		property := "obj.list[2].map[wot].meth(judge, dredd).str().prop"
		
		fieldName	:= sequence([
			firstOf([str("_"), anyAlphaChar]), 
			zeroOrMore(firstOf([str("_"), anyAlphaNumChar]))
		]) { it.name = "fieldName" }
		basicField	:= fieldName.dup
		indexName	:= oneOrMore(anyAlphaNumChar) { it.name = "indexName" }
		indexField	:= sequence([fieldName.dup, str("["), indexName, str("]")])
		beanField	:= sequence([firstOf([indexField, basicField]), optional(str("."))])
		parser  	:= Parser(beanField, property.in)
		matches 	:= parser.parseAll
	}
}
