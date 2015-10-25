using afPegger

class Example : Rules {
    Void main() {
        nameRule   := oneOrMore(anyAlphaChar).withAction |Str match| { echo(match) }
        parseRules := sequence([char('<'), nameRule, char('>')])

        Parser(parseRules).parse("<HelloMum>".in)  // --> HelloMum
    }
}