
https://github.com/jgm/peg-markdown/blob/master/markdown_parser.leg

https://pegjs.org/documentation#grammar-syntax-and-semantics-parsing-expression-types

https://tools.ietf.org/html/rfc5234

http://bford.info/packrat/

https://nim-lang.org/docs/pegs.html

CSS
https://developer.mozilla.org/en-US/docs/Web/CSS/Syntax
https://developer.mozilla.org/en-US/docs/Web/CSS/At-rule
https://developer.mozilla.org/en-US/docs/Web/CSS/@media
https://developer.mozilla.org/en-US/docs/Web/CSS/Comments


For 1.0.0
=========

Don't wait until the very end before we call the actions. We should always know if we're going to advance or not.
Actually, bullshit - the first rule could always fail and rollback!

spit out a peg tree

peg parser!
add more symbols :
http://nimrod-lang.org/pegs.html
add notion of {capturing} for replace...?

Pegex -> matches, matched, find, replace, etc

add peg(Str peg) to rules for parsing PEG grammer into a rule, kind of a shortcut for sequence([anyAlphaChar, anyNumChar]) -> peg("[a-Z] / 0-9") 

For Future
==========

