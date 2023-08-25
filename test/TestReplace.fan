
@Js
internal class TestReplace : Test {
	
	Void testFind() {
		peg := Peg("a12 + b23 / c69 * z666", "foo:[a-z] [0-9]+")
		verifyEq(peg.find,			"a12")
		verifyEq(peg.find,			"b23")
		verifyEq(peg.find("foo"),	"c")
		verifyEq(peg.find("foo"),	"z")
	}

	Void testReplace1() {
		str := "(34) -> {12}"
		pat := "foo:[0-9]+ [^0-9]+ bar:[0-9]+"
		peg := Peg(str, pat)
		
		// order this so we can check the order of replacements
		rep := Str:Str[:]
		rep.ordered = true
		rep["foo"] = "fooo"
		rep["bar"] = "barr"

		val := peg.replace(rep)
		verifyEq(val, "(fooo) -> {barr}")
	}

	Void testReplace2() {
		str := "(34) -> {12}"
		pat := "foo:[0-9]+ [^0-9]+ bar:[0-9]+"
		peg := Peg(str, pat)
		val := peg.replace(["foo":"\${bar}", "bar":"\${foo}"])
		verifyEq(val, "(12) -> {34}")
	}
	
	Void testReplaceAll() {
		str := "I like abba!"
		pat := "(foo:'a' / bar:'b')"
		peg := Peg(str, pat)
		val := peg.replaceAll(["foo":"b", "bar":"a"])
		verifyEq(val, "I like baab!")
	}
}
