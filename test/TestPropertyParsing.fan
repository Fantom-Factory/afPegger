
@Js
internal class TestPropertyParsing : Test, Rules {
	
	Void testNuffin() {		
		property := "obj.list[2].map[wot].meth(judge, dredd).str().prop"
		
		fieldName	:= sequence([
			firstOf([str("_"), alphaChar]), 
			zeroOrMore(firstOf([str("_"), alphaNumChar]))
		]) { it.name = "fieldName" }
		indexName	:= oneOrMore(alphaNumChar) { it.name = "indexName" }
		indexField	:= sequence([fieldName, str("["), indexName, str("]")])
//		beanField	:= sequence([firstOf([indexField, basicField]), optional(str("."))])
//		parser  	:= Parser(beanField, property.in)
//		matches 	:= parser.parseAll
	}
}
