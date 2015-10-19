
@Js
class TreeRules : Rules {

	Rule push(Str type, Obj? data := null) {
		doAction(pushAction(type, data))
	}
	
	Rule add(Str type, Obj? data := null) {
		doAction(addAction(type, data))
	}
	
	Rule pop() {
		doAction(popAction)
	}
	
	|Str matched, Obj? ctx| pushAction(Str type, Obj? data := null) {
		|Str matched, Obj? ctx| { ((TreeCtx) ctx).push(type, matched, data) }
	}

	|Str matched, Obj? ctx| addAction(Str type, Obj? data := null) {
		|Str matched, Obj? ctx| { ((TreeCtx) ctx).add(type, matched, data) }
	}

	|Str matched, Obj? ctx| popAction() {
		|Str matched, Obj? ctx| { ((TreeCtx) ctx).pop() }
	}
}


@Js
class TreeCtx {
	TreeItem[]	items	:= TreeItem[TreeItem("root")]

	Void push(Str type, Str? matched := null, Obj? data := null) {
		item := TreeItem(type, matched, data)
		items.last.add(item)
		items.push(item)
	}

	Void add(Str type, Str? matched := null, Obj? data := null) {
		item := TreeItem(type, matched, data)
		items.last.add(item)
	}

	Void pop() {
		items.pop
	}

	TreeItem root() {
		items.first
	}
	
	override Str toStr() {
		items.join("\n")
	}
}

@Js
class TreeItem {
	TreeItem[]	items	:= TreeItem#.emptyList
	Str			type
	Str?		matched
	Obj?		data

	new make(Str type, Str? matched := null, Obj? data := null) {
		this.type		= type
		this.matched	= matched
		this.data		= data
	}
	
	Void add(TreeItem item) {
		if (items.isRO)
			items = TreeItem[,]
		items.add(item)
	}
	
	Void walk(|TreeItem| enter, |TreeItem| exit) {
		enter(this)
		items.each { it.walk(enter, exit) }
		exit(this)
	}
	
	override Str toStr() {
		str := type + ":" + (data ?: "") + ":" + (matched?.toCode(null) ?: "")
		if (items.size > 0)
			str += "\n" + items.join("\n").splitLines.map { "    ${it}" }.join("\n")
		return str
	}
}
