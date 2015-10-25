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

    
    Void main() {
        echo(parse("(2 + (12 - 3)) * ((15 % 3) - 2 * 3) + 4"))
    }
}
