# Pegger v1.1.6
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v1.1.6](http://img.shields.io/badge/pod-v1.1.6-yellow.svg)](http://eggbox.fantomfactory.org/pods/afPegger)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## <a name="overview"></a>Overview

Parsing Expression Grammar (PEG) for when Regular Expressions just aren't enough!

Pegger is a [Parsing Expression Grammar (PEG)](http://pdos.csail.mit.edu/~baford/packrat/popl04/peg-popl04.pdf) implementation. It lets you create text parsers by building up a tree of simple matching [rules](http://eggbox.fantomfactory.org/pods/afPegger/api/Rules).

Advanced parsing options let you *look ahead* with predicates and the returned tree of match results gives you plenty of options for transforming it into useful data.

Pegger was inspired by [Mouse](http://www.romanredz.se/papers/CSP2009.Mouse.pdf), [Parboiled](https://github.com/sirthias/parboiled/wiki), and [nim pegs](https://nim-lang.org/docs/pegs.html).

## <a name="Install"></a>Install

Install `Pegger` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afPegger

Or install `Pegger` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afPegger

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afPegger 1.1"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afPegger/) - the Fantom Pod Repository.

## <a name="quickStart"></a>Quick Start

    using afPegger::Peg
    
    class Example {
        Void main() {
            input := "<<<Hello Mum>>>"
            rule  := "'<'+ name:[a-zA-Z ]+ '>'+"
            match := Peg(input, rule).match
    
            name  := match["name"]    // --> "Hello Mum"
        }
    }
    

## <a name="usage"></a>Usage

The quick start example saw a lot of crazy symbols... so woah, what just happened?

### <a name="rules"></a>Rules

Pegger attempts to match a `rule` against a given string. In the example the string was `<<<Hello Mum>>>` and the rule was that mixed bag of crazy characters. Rules can be written in PEG notation (see mixed bag of crazy characters) or they can be created programmatically via Fantom code using the [Rules](http://eggbox.fantomfactory.org/pods/afPegger/api/Rules) mixin:

    // PEG Notation:
    // '<'+ ([a-zA-Z] / " ")+ '>'+
    
    // Fantom code:
    rule := sequence {
        oneOrMore(char('<')),
        oneOrMore(firstOf { alphaChar, spaceChar }),
        oneOrMore(char('>')),
    }
    

The Fantom code can be a lot simplier to read and understand, but is also a lot more verbose.

Once you run a match, the result is a tree. Use `Match.dump()` to see it:

    rule := sequence {
        oneOrMore(char('<')),
        oneOrMore(firstOf { alphaChar, spaceChar }),
        oneOrMore(char('>')),
    }
    
    input := "<<<Hello Mum>>>"
    match := Peg(input, rule).match
    match.dump
    
    // --> root : "<<<Hello Mum>>>"
    
    

Okay, so that's not much of a tree. To create a tree, we need to give parts of our rule a label, or a name:

    rule := sequence {
        oneOrMore(char('<'))                       .withName("start"),
        oneOrMore(firstOf { alphaChar, spaceChar }).withName("name"),
        oneOrMore(char('>'))                       .withName("end"),
    }
    

We can do the same in PEG notation by using a `label:` prefix:

    // PEG Notation:
    // start:'<'+ name:[a-zA-Z ]+ end:'>'+
    

`match.dump()` now gives:

    root
     ├─ start : "<<<"
     ├─ name : "Hello Mum"
     └─ end : ">>>"
    

Each part of the match may be retreived using the `Match.get()` operator:

    match["start"].toStr  // -> "<<<"
    match["name"].toStr   // -> "Hello Mum"
    match["end"].toStr    // -> ">>>"
    

### <a name="grammer"></a>Grammar

The same could also be written as PEG grammar. Grammar defines multiple PEG rules. Grammars may be coded programmatically but are usually created from a string. There should always be the one *top-level* or *root* rule which is responsible for matching everything:

    root  = start name end
    start = '<'+
    name  = [a-zA-Z ]+
    end   = '>'+
    

Definitions may span multiple lines but proceeding lines *must* contain leading whitespace to distinguish it from a new rule definition.

    root  = start
            name
            end
    start = '<'+
    name  = [a-zA-Z ]+
    end   = '>'+
    

When run, the same result is given:

    grammarStr := "..."
    grammar    := Peg.parseGrammar(grammarStr)
    
    input      := "<<<Hello Mum>>>"
    match      := grammar["root"].match(input).dump
    
    // root
    //  ├─ start : "<<<"
    //  ├─ name : "Hello Mum"
    //  └─ end : ">>>"
    

Once a grammar (or rule) has been parsed, it may be cached for future re-use.

Rules may be omitted from the result tree by prefixing the definitions with a `-`:

    root   = start name end
    -start = '<'+
    name   = [a-zA-Z ]+
    -end   = '>'+
    
    // root
    //  └─ name : "Hello Mum"
    

## <a name="pegNotation"></a>PEG Notation

Writing grammar files can be a lot easier to understand than the verbose programatic method. Here's your guide.

Pegger is primarily concerned with parsing displayable 7-bit ASCII characters, but where mentioned also provides support for 16-bit Unicode characters. Non-visible / non-printable characters are beyond the remit of Pegger; largely because Pegger uses strings as input! See [Design notes](#designNotes) for details.

#### <a name="ruleDefinitions"></a>Rule definitions

A rule is defined with a name followed by `=`. The more formal definition of `<-` may be used in place of `=`.

    ruleDef1  = rule
    ruleDef2 <- rule

**Advanced Note:** Prefixing a rule with `-` will remove it from the result tree.

    -ruleDef1  = rule
    -ruleDef2 <- rule

**Advanced Note:** Suffixing a rule with `-` will remove it from debug output.

    ruleDef1-  = rule
    ruleDef2- <- rule

Rules may have both a `-` prefix and suffix: `-ruleDef- = rule`

#### <a name="sequence"></a>Sequence

Ordered sequences of rules are expressed by separating them with a space.

    ruleDef = rule1 rule2 rule3

#### <a name="choice"></a>Choice / First of

When given a choices, Pegger will match the *first* rule that passes. **Beware:** order of choices *can* be important.

    ruleDef = rule1 / rule2 / rule3

#### <a name="grouping"></a>Grouping

Choice rules have a higher operator precedence than Sequence rules, but it is better to group rules with brackets to avoid ambiguity.

    ruleDef = (rule1 rule2) / (rule3 rule4)

#### <a name="repitition"></a>Repetition

Rules may be specified to be matched by different amounts.

    rule1?      // optional
    rule1+      // one or more
    rule1*      // zero or more
    rule1{2,6}  // between 2 and 6 (inclusive)
    rule1{,5}   // at most 5 - same as {0,5}
    rule1{3,}   // at least 3

#### <a name="literal"></a>Literal

Literal strings may be matched with either single or double quotes.

    ruleDef1 = "literal 1"
    ruleDef2 = 'literal 2'

Use backslash to escape the usual `\b \f \n \r \t` characters and to escape quotes. (Note that Fantom *normalises* all new line characters to just `\n`.)

Use an `i` suffix to indicate the match should be case-insensitive.

    ruleDef3 = "new\nline\n"i

#### <a name="character"></a>Character class

Individual characters, and ranges thereof, may be matched with a regex-esque character class.

    ruleDef1 = [a]        // matches a
    ruleDef2 = [abc]      // matches 'a', 'b', or 'c'
    ruleDef3 = [a-z]      // matches any character in the range from 'a' to 'z' inclusive
    ruleDef4 = [a-z]i     // as above, but case-insensitive
    ruleDef5 = [0-9A-F]i  // matches any hex digit
    ruleDef6 = [\n\] \t]  // backslash escapes

The hat `^` character will match any character BUT the chosen ones.

    ruleDef6 = [^0-9]     // match any char BUT not digits

#### <a name="any"></a>Any character

Use `.` to match *any* character.

    ruleDef = . . .       // matches any 3 characters

#### <a name="predicate"></a>Predicates

Use the ampersand `&` to look ahead for a match, but NOT consume any characters.

    ruleDef = "something " &"good" .

Use exclamation `!` to look ahead for a negative match, but again, NOT consume any characters.

    ruleDef = "something " !"bad" .

#### <a name="unicode"></a>Unicode

Use `\uXXXX` (hexadecimal) notation to match a 16-bit unicode character. May be used in string literals and character classes.

    crlf = [\u000D] "\u000A"

#### <a name="macros"></a>Macros

Pegger introduces macros for useful extensions. These may be used individually as rules.

    table:
    name        function
    ----------  ---------------------------------
    \eos        Matches End-Of-Stream (or End-Of-String!?)
    \eol        Matches End-Of-Line - either a new-line char or EOS
    \lower      Matches a lowercase character in the current locale
    \upper      Matches an uppercase character in the current locale
    \alpha      Matches a character in the current locale
    \err(xxx)   Throws a parse error when processed
    \noop(xxx)  No-Operation, does nothing, but prints the message to the console when run
    

#### <a name="comments"></a>Comments

Hash `#` comments are allowed in grammar, as are double slash `//` comments.

    #  Hash comments are allowed in grammar
    // as are double slash comments
    
    a = .  // end-of-line comments also allowed
    
    b = [cd]
        // comments may also appear inbetween rules
        [de]

## <a name="pegGrammer"></a>PEG Grammar

Interestingly, PEG grammar may itself be expressed as PEG grammar. And indeed, Pegger *does* use itself to parse your PEG definitions!

PEG grammar:

    grammar      <- (!\eos (commentLine / ruleDef / \err(FAIL)))+
    ruleDef      <- exclude:"-"? ruleName debugOff:"-"? cwsp* ("=" / "<-") cwsp* rule commentLine?
    ruleName     <- [a-zA-Z] (("-" [a-zA-Z0-9_]) / [a-zA-Z0-9_])*
    rule         <- firstOf / \err(FAIL-2)
    firstOf      <- sequence (cwsp* "/" cwsp* sequence)*
    sequence     <- expression (cwsp* expression)*
    expression   <- predicate? (label ":")? type multiplicity?
    label        <- [a-zA-Z] [a-zA-Z0-9_\-]*
    type         <- group / ruleName / literal / chars / macro / dot
    -group       <- "(" cwsp* rule cwsp* ")"
    predicate    <- "!" / "&"
    multiplicity <- "*" / "+" / "?" / ("{" min:[0-9]* "," max:[0-9]* "}")
    literal      <- singleQuote / doubleQuote
    -singleQuote <- "'" (unicode / ("\\" .) / [^'])+ "'" "i"?
    -doubleQuote <- "\"" (unicode / ("\\" .) / [^"])+ "\"" "i"?
    chars        <- "[" (unicode / ("\\" .) / [^\]])+ "]" "i"?
    macro        <- "\\" [a-zA-Z]+ ("(" [^)\n]* ")")?
    unicode      <- "\\" "u" [0-9A-F]i [0-9A-F]i [0-9A-F]i [0-9A-F]i
    dot          <- "."
    commentLine  <- sp* (\eol / comment)
    comment-     <- ("#" / "//") (!\eos [^\n])* \eol
    -cwsp-       <- sp / (!\eos cnl (sp / &("#" / "//")))
    -cnl-        <- \eol / comment
    -sp-         <- [ \t]
    

## <a name="recursive"></a>Recursive / HTML Parsing

A well known limitation of regular expressions is that they can not match nested patterns, such as HTML. (See [StackOverflow for explanation](http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454).) Pegger to the rescue!

Because PEGs contain rules that may reference themselves in a circular fashion, it is possible to create recursive parsers.

Below is an example that parses nested HTML tags. You can see the recursion from the `element` definition which references itself:

    grammar := Peg.parseGrammar("element  = startTag (element / text)* endTag
                                 startTag = '<'  name:[a-z]i+ '>'
                                 endTag   = '</' name:[a-z]i+ '>'
                                 text     = [^<]+")
    
    html    := "<html><head><title>Pegger Example</title></head><body><p>Parsing is Easy!</p></body></html>"
    
    grammar["element"].match(html).dump
    Peg(html, element).match.dump
    

Which outputs the following result tree:

    element
     ├─ startTag
     │   └─ name : "html"
     ├─ element
     │   ├─ startTag
     │   │   └─ name : "head"
     │   ├─ element
     │   │   ├─ startTag
     │   │   │   └─ name : "title"
     │   │   ├─ text : "Pegger Example"
     │   │   └─ endTag
     │   │       └─ name : "title"
     │   └─ endTag
     │       └─ name : "head"
     ├─ element
     │   ├─ startTag
     │   │   └─ name : "body"
     │   ├─ element
     │   │   ├─ startTag
     │   │   │   └─ name : "p"
     │   │   ├─ text : "Parsing is Easy!"
     │   │   └─ endTag
     │   │       └─ name : "p"
     │   └─ endTag
     │       └─ name : "body"
     └─ endTag
         └─ name : "html"
    

Parsing has never been easier!

*Note that only **Chuck Norris** can parse HTML with regular expressions.*

Converting the match results into XML is left as an excerise for the user, but there are a couple of options open to you:

### <a name="looping"></a>1. Looping

This is usually the easiest way to convert your match results, but not always the cleanest.

It involves looping over the match results the same as you would with any other list, and recursively calling yourself to convert inner data.

### <a name="walking"></a>2. Walking

Create a `walk()` method that recursively calls a given function every time it steps into, or out of, a match:

    Void walk(Match match, |Match, Str startOrEnd| fn) {
        fn?.call(match, "start")
        match.matches.each { walk(it, fn) }
        fn?.call(match, "end")
    }
    

## <a name="customRules"></a>Custom Rules

Custom rules may be created by subclassing the [Rule](http://eggbox.fantomfactory.org/pods/afPegger/api/Rule) class.

There (currently) is no support for introducing custom rules in PEG grammar, so use of custom rules limits their use to inclusion in programmatic Fantom based grammars.

## <a name="debugging"></a>Debugging

By enabling debug logging, `Pegger` will spew out a *lot* of debug / trace information. (Possiblly more than you can handle!) But note it will only emit debug information for rules with names or labels.

Enable debug logging with the line:

    Peg.debugOn
    
    // or
    
    Log.get("afPegger").level = LogLevel.debug

Which, for the above html parsing example, will generate the following:

    [afPegger] [  1] --> element - Processing: startTag (element / text)* endTag with: <html><title>Pegger Ex...
    [afPegger] [  2]  --> startTag - Processing: "<" [a-zA-Z]+ ">" with: <html><title>Pegger Ex...
    [afPegger] [  2]    > startTag - Passed!
    [afPegger] [  2]    > startTag - Matched: "<html>"
    [afPegger] [  4]    --> element - Processing: startTag (element / text)* endTag with: <title>Pegger Example<...
    [afPegger] [  5]     --> startTag - Processing: "<" [a-zA-Z]+ ">" with: <title>Pegger Example<...
    [afPegger] [  5]       > startTag - Passed!
    [afPegger] [  5]       > startTag - Matched: "<title>"
    [afPegger] [  7]       --> element - Processing: startTag (element / text)* endTag with: Pegger Example</title>...
    [afPegger] [  8]        --> startTag - Processing: "<" [a-zA-Z]+ ">" with: Pegger Example</title>...
    [afPegger] [  8]          > startTag - Did not match "<".
    [afPegger] [  8]          > startTag - Failed. Rolling back.
    [afPegger] [  7]         > element - Did not match startTag.
    [afPegger] [  7]         > element - Failed. Rolling back.
    [afPegger] [  7]       --> text - Processing: (!"<" .)+ with: Pegger Example</title>...
    [afPegger] [  7]         > text - Rule was successfully processed 14 times
    [afPegger] [  7]         > text - Passed!
    [afPegger] [  7]         > text - Matched: "Pegger Example"
    ...
    ...
    ...
    

## <a name="designNotes"></a>Design notes

Pegger was purposefully designed to match strings or more specifically, **Unicode character data** (of variable byte length dependant on encoding) - **not binary data**. Hence it lacks notation to match bytes and byte ranges as seen in some RFC documents.

If required, hexadecimal Unicode escape sequences ( `\uXXXX` ) may be used to represent 8-bit binary data.

