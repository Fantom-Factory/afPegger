#Pegger v0.1.0
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v0.1.0](http://img.shields.io/badge/pod-v0.1.0-yellow.svg)](http://www.fantomfactory.org/pods/afPegger)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

*Pegger is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

For when Regular Expressions just aren't enough!

Pegger is a [Parsing Expression Grammar (PEG)](http://pdos.csail.mit.edu/~baford/packrat/popl04/peg-popl04.pdf) implementation. It lets you create text parsers by building up a tree of simple matching [rules](http://pods.fantomfactory.org/pods/afPegger/api/Rules).

Pegger was inspired by [Mouse](http://www.romanredz.se/papers/CSP2009.Mouse.pdf) and [Parboiled](https://github.com/sirthias/parboiled/wiki).

## Install

Install `Pegger` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://pods.fantomfactory.org/fanr/ afPegger

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afPegger 0.1"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afPegger/).

## Quick Start

```
using afPegger

class Example : Rules {
    Void main() {
        nameRule   := oneOrMore(anyAlphaChar).withAction |Str match| { echo(match) }
        parseRules := sequence([char('<'), nameRule, char('>')])

        Parser(parseRules).parse("<HelloMum>".in)  // --> HelloMum
    }
}
```

## Usage

When parsing text, `Pegger` on it's own will not return anything useful. Instead it is up to you to assign useful actions to rules that get executed when it is successfully matched against text.

The [Rules](http://pods.fantomfactory.org/pods/afPegger/api/Rules) mixin contains a lot of useful pre-written rules. But should you require more dynamic behaviour, you can always extend Pegger by implementing your own [Rule](http://pods.fantomfactory.org/pods/afPegger/api/Rule).

Pegger is stream based, meaning it will only consume as much of the input stream as it needs to verify that the next rule passes / fails.

## Tree Rules

When parsing text, it is often useful to build tree structures. For example, a calculator may build a tree of nested expressions.

```
(2 + 2) * (5 - 2) + 3

calc::
    calc::
        number::2
        op::+
        number::2
    op::*
    calc::
        number::5
        op::-
        number::2
    op::+
    number::3
```

[TreeRules](http://pods.fantomfactory.org/pods/afPegger/api/TreeRules) extend the standard `Rules` mixin to allow you to do just that.

```
using afPegger

class Calculator : TreeRules {
    private Str:Func ops := [
        "+" : |Float a, Float b -> Float| { a + b },
        "-" : |Float a, Float b -> Float| { a - b },
        "*" : |Float a, Float b -> Float| { a * b },
        "%" : |Float a, Float b -> Float| { a / b }
    ]

    Float parse(Str text) {
        parser := Parser(calculatorRules)
        tree   := (TreeCtx) parser.parseAll(text.in, TreeCtx())

        echo(tree)

        tree.root.walk(null,
            |TreeItem item| {
                if (item.type == "calc") {
                    op  := (Str?) null
                    item.data = item.items.reduce(0f) |Float total, itm, i->Float| {
                        if (itm.type == "op") {
                            op = itm.matched
                            return total
                        }
                        number := itm.type == "number" ? itm.matched.toFloat : itm.data
                        return i == 0 ? number : ops[op](total, number)
                    }
                }
            }
        )

        return tree.root.items.first.data
    }

    Rule calculatorRules() {
        rules               := NamedRules()
        expression          := rules["expression"]
        number              := rules["number"]
        operator            := rules["operator"]
        calc                := rules["calc"]

        rules["number"]     = oneOrMore(anyNumChar).withAction(addAction("number"))
        rules["operator"]   = anyCharOf("+-*%".chars).withAction(addAction("op"))
        rules["expression"] = firstOf { number, sequence { char('('), calc, char(')'), }, }
        rules["calc"]       = sequence { push("calc"), expression, oneOrMore(sequence { anySpaceChar, operator, anySpaceChar, expression, }), pop }

        return calc
    }
}
```

Try it with:

```
expression := "(2 + 2) * (5 - 2) + 3"
Calculator().parse(expression)  // --> 15.0

expression = "(2 + (12 - 3)) * ((15 % 3) - 2 * 3) + 4"
Calculator().parse(expression)  // --> 103.0
```

## Recursive / HTML Parsing

A well known limitation of regular expressions is that they can not match nested patterns, such as HTML. (See [StackOverflow for explanation](http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454).) Pegger to the rescue!

Below is an example that parses nested HTML tags into XML and throws a `ParseErr` should an incorrect end tag be used. It uses the [NamedRules](http://pods.fantomfactory.org/pods/afPegger/api/NamedRules) helper class to reference rules to get around inherent problems with recursion.

```
using xml
using afPegger

class Example {
  Void main() {
    Parser#.pod.log.level = LogLevel.debug
    elem := TagParser().parseTags("<html><title>Pegger Example</title><body>Parsing is Easy!</body></html>")

    echo(elem.writeToStr)  // -->
                           // <html>
                           //  <title>Pegger Example</title>
                           //  <body>Parsing is Easy!</body>
                           // </html>

    elem = TagParser().parseTags("<html><title>Pegger Example</oops></html>")
                           // --> sys::ParseErr: End tag </oops> does not match start tag <title>
  }
}

class TagParser : Rules {
  XElem?  root
  XElem?  elem

  XElem parseTags(Str tags) {
    Parser(rules).parse(tags.in)
    return root
  }

  Rule rules() {
    // use 'NamedRules' to define rules in any order and to avoid recursion
    rules    := NamedRules()
    element  := rules["element"]
    startTag := rules["startTag"]
    endTag   := rules["endTag"]
    text     := rules["text"]

    rules["element"]  = sequence([startTag, zeroOrMore(firstOf([element, text])), endTag])
    rules["startTag"] = sequence([char('<'), oneOrMore(anyAlphaChar), char('>')]) .withAction { pushStartTag(it) }
    rules["endTag"]   = sequence([str("</"), oneOrMore(anyAlphaChar), char('>')]) .withAction { pushEndTag(it) }
    rules["text"]     = oneOrMore(anyCharNot('<'))                                .withAction { pushText(it) }

    return element
  }

  Void pushStartTag(Str tagName) {
    child := XElem(tagName[1..<-1])
    if (root == null)
      root = child
    else
      elem.add(child)
    elem = child
  }

  Void pushEndTag(Str tagName) {
    if (tagName[2..<-1] != elem.name)
      throw ParseErr("End tag ${tagName} does not match start tag <${elem.name}>")
    elem = elem.parent
  }

  Void pushText(Str text) {
    elem.add(XText(text))
  }
}
```

Note that only *Chuck Norris* can parse HTML with regular expressions.

## Debug

By enabling debug logging, `Pegger` will spew out a *lot* of debug / trace information. (Possiblly more than you can handle!) But note it will only emit debug information for rules with names.

Enable debug logging with the line:

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

