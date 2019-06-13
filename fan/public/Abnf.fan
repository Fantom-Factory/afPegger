
**
** Augmented Backus-Naur Form (ABNF)
** 
** See [RFC 5234]`https://tools.ietf.org/html/rfc5234`.
** 
@Js
class Abnf {
	
	** Parses a ABNF grammar definitions.
	** For example:
	** 
	**   syntax: fantom 
	**   parseAbnf(
	**     "a <- [abc] / [xyz] / b
	**      b <- \space+ [^abc]"
	**   )
	** 
	static Grammar parseAbnf(Str grammar) {
		AbnfGrammar().parseGrammar(grammar)
	}
	
	** Returns the grammar uses to parse ABNF grammar.
	** 
	** It's not particularly useful, but it may be interesting to some.
	static Grammar abnfGrammar() {
		AbnfGrammar.abnfGrammar
	}
}
