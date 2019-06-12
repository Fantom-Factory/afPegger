# Pegger v1.0.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v1.0.0](http://img.shields.io/badge/pod-v1.0.0-yellow.svg)](http://eggbox.fantomfactory.org/pods/afPegger)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Parsing Expression Grammar (PEG) for when Regular Expressions just aren't enough!

Pegger is a [Parsing Expression Grammar (PEG)](http://pdos.csail.mit.edu/~baford/packrat/popl04/peg-popl04.pdf) implementation. It lets you create text parsers by building up a tree of simple matching [rules](http://eggbox.fantomfactory.org/pods/afPegger/api/Rules).

Advanced parsing options let you *look ahead* with predicates and the returned tree of match results gives you plenty of options for transforming it into useful data.

Pegger was inspired by [Mouse](http://www.romanredz.se/papers/CSP2009.Mouse.pdf) and [Parboiled](https://github.com/sirthias/parboiled/wiki).

## Install

Install `Pegger` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afPegger

Or install `Pegger` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afPegger

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afPegger 1.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afPegger/) - the Fantom Pod Repository.

## Quick Start

```
using afPegger::Peg

class Example {
    Void main() {
        input := "<<<Hello Mum>>>"
        rule  := "'<'+ name:[a-zA-Z ]+ '>'+"
        match := Peg(input, rule).match

        name  := match["name"]    // --> "Hello Mum"
    }
}
```

## Usage

The quick start example saw a lot of crazy symbols... so woah, what just happened?

### Rules

Pegger attempts to match a `rule` against a given string. In the example the string was `<<<Hello Mum>>>` and the rule was that mixed bag of crazy characters. Rules can be written in PEG notation (see mixed bag of crazy characters) or they can be created programmatically via Fantom code using the [Rules](http://eggbox.fantomfactory.org/pods/afPegger/api/Rules) mixin:

```
// PEG Notation:
// '<'+ ([a-zA-Z] / " ")+ '>'+

// Fantom code:
rule := sequence { oneOrMore(char('<')), oneOrMore(firstOf { alphaChar, spaceChar }), oneOrMore(char('>')), }

```

The Fantom code can be a lot simplier to read and understand, but is also a lot more verbose.

Once you run a match, the result is a tree. Use `Match.dump()` to see it:

```
rule := sequence { oneOrMore(char('<')), oneOrMore(firstOf { alphaChar, spaceChar }), oneOrMore(char('>')), }

input := "<<<Hello Mum>>>"
match := Peg(input, rule).match
match.dump

// --> root : "<<<Hello Mum>>>"

```

Okay, so that's not much of a tree. To create a tree, we need to give parts of our rule a label, or a name:

```
rule := sequence {
  oneOrMore(char('<')).withName("start"),
  oneOrMore(firstOf { alphaChar, spaceChar }).withName("name"),
  oneOrMore(char('>')).withName("end"),
}
```

We can do the same in PEG notation by using a `label:` prefix:

```
rule := "start:'<'+ name:[a-zA-Z ]+ end:'>'+"
```

`match.dump()` now gives:

```
root
 ├─ start : "<<<"
 ├─ name : "Hello Mum"
 └─ end : ">>>"
```

Each part of the match may be retreived using the `Match.get()` operator:

```
match["start"].toStr  // -> "<<<"
match["name"].toStr   // -> "Hello Mum"
match["end"].toStr    // -> ">>>"
```

### Grammar

The same could also be written as PEG grammar. Grammar defines multiple PEG rules. Grammars may be coded programmatically but are often created from a string. They need to define an overriding *root* rule which responsible matching everything:

```
root  <- start name end
start <- '<'+
name  <- [a-zA-Z ]+
end   <- '>'+
```

Each definition must be placed on its own line, and may also be written in a more standard property file notation using `=`:

```
#  Hash comments are allowed in grammar
// as are double slash comments

root  = start name end
start = '<'+
name  = [a-zA-Z ]+
end   = '>'+
```

When run, the same result is given:

```
grammarStr := "..."
grammar    := Peg.parseGrammar(grammarStr)
rootRule   := grammar["root"]

match      := Peg(input, rootRule).match
match.dump
```

Once a grammar (or rule) has been parsed, it may be cached for future re-use.

## Macros

Pegger introduces macros for common or useful extensions. These may be used directly in your PEG expressions:

```
table:
name        function
----------  ---------------------------------
\a          Matches any alpha char - 'a-zA-Z'
\d          Matches any digit - '0-9'
\n          Matches new-line char - '\n'
\s          Matches any whitespace char - ' \t\n'
\w          Matches any word char - 'a-zA-Z0-9_'
\sp         Matches space or tab char - ' \t'
\eol        Matches End-Of-Line - new-line char or EOS
\eos        Matches End-Of-Stream - or End-Of-String
\err(xxx)   Throws a parse error when processed
\noop(xxx)  No-Operation, does nothing
```

## PEG Grammar

Interestingly, PEG grammar may itself be expressed as PEG grammar. And indeed, Pegger *does* use itself to parse your PEG definitions!

PEG grammar:

```
grammar      <- (!\eos line)+
line         <- emptyLine / commentLine / ruleDef / \err(FAIL)
emptyLine    <- sp* \eol
commentLine  <- sp* ("#" / "//") sp* comment \eol
comment      <- [^\n]*
ruleDef      <- ruleName sp* ("=" / "<-") sp* rule sp* \eol
ruleName     <- [a-zA-Z] [a-zA-Z0-9_\-]*
rule         <- firstOf / sequence / \err(FAIL)
sequence     <- expression (sp+ expression)*
firstOf      <- expression sp* "/" sp* expression (sp* "/" sp* expression)*
expression   <- predicate? (label ":")? type multiplicity?
label        <- [a-zA-Z] [a-zA-Z0-9_\-]*
type         <- ("(" sp* rule sp* ")") / ruleName / literal / chars / macro / dot
predicate    <- "!" / "&"
multiplicity <- "*" / "+" / "?"
literal      <- singleQuote / doubleQuote
singleQuote  <- "'" (unicode / ("\\" .) / [^'])+ "'" "i"?
doubleQuote  <- "\"" (unicode / ("\\" .) / [^"])+ "\"" "i"?
chars        <- "[" (unicode / ("\\" .) / [^\]])+ "]" "i"?
macro        <- "\\" [a-zA-Z]+ ("(" [^)\n]* ")")?
unicode      <- "\\" "u" [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9]
dot          <- "."
sp           <- [ \t]
```

## Recursive / HTML Parsing

A well known limitation of regular expressions is that they can not match nested patterns, such as HTML. (See [StackOverflow for explanation](http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454).) Pegger to the rescue!

Because PEGs contain rules that may reference themselves in a circular fashion, it is possible to create recursive parsers.

Below is an example that parses nested HTML tags. You can see the recursion from the `element` definition which references itself:

```
pegDefs := "element  = startTag (element / text)* endTag
            startTag = '<'  name:[a-z]i+ '>'
            endTag   = '</' name:[a-z]i+ '>'
            text     = [^<]+"
grammar := Peg.parseGrammar(pegDefs)
element := grammar["grammar"]

html := parseHtml("<html><head><title>Pegger Example</title></head><body><p>Parsing is Easy!</p></body></html>")

Peg(html, element).match.dump

```

Which outputs the following result tree:

```
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
```

Parsing has never been easier!

*Note that only **Chuck Norris** can parse HTML with regular expressions.*

Converting the match results into XML is left as an excerise for the user, but there are a couple of options open to you:

### 1. Looping

This is usually the easiest way to convert your match results, but not always the cleanest.

It involves looping over the match results the same as you would with any other list, and recursively calling yourself to convert inner data.

### 2. Walking

Create a `walk()` method that recursively calls a given function every time it steps into, or out of, a match:

```
Void walk(Match match, |Match, Str startOrEnd| fn) {
    fn?.call(match, "start")
    match.matches.each { walk(it, fn) }
    fn?.call(match, "end")
}
```

### 3. Rule Actions

You can add action functions to rules. Functions are called when the rule is successfully matched.

Note that action functions are only called once all matching has been completed. That way functions are not called when sequences are being explored, or before predicates are rolled back.

```
grammar["startTag"].withAction |tagName| { echo("startTag: $tagName") }
grammar["text"    ].withAction |text|    { echo("text: $text") }
grammar["endTag"  ].withAction |tagName| { echo("endTag: $tagName") }
```

## Debugging

By enabling debug logging, `Pegger` will spew out a *lot* of debug / trace information. (Possiblly more than you can handle!) But note it will only emit debug information for rules with names.

Enable debug logging with the line:

    Peg.debugOn
    
    // or
    
    Log.get("afPegger").level = LogLevel.debug

Which, for the above html parsing example, will generate the following:

```
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
```

