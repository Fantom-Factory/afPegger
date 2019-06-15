
**
** Parsers for Backus-Naur Form (BNF) and Augmented BNF.
** 
** See [RFC 5234]`https://tools.ietf.org/html/rfc5234`.
** 
@Js
class Bnf {
	
	** Parses a ABNF grammar definitions.
	** For example:
	** 
	**   syntax: fantom 
	**   parseAbnf(
	**     "a <- [abc] / [xyz] / b
	**      b <- \space+ [^abc]"
	**   )
	** 
	static Grammar parseBnf(Str grammar) {
		BnfGrammar().parseGrammar(grammar)
	}
	
	** Returns the grammar uses to parse ABNF grammar.
	** 
	** It's not particularly useful, but it may be interesting to some.
	static Grammar bnfGrammar() {
		BnfGrammar.bnfGrammar
	}
	
//	static Str bnfToPeg(Str bnf) {
//		parseBnf(grammar).definition
//	}
}
