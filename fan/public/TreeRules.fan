
@Js
class TreeRules : Rules {

	Rule push(Str type, Obj? data := null) {
		doAction(pushAction(type, data))
	}
	
	Rule add(Str type, Obj? data := null) {
		doAction(addAction(type, data))
	}
	
	Rule pop(Str? type := null) {
		doAction(popAction(type))
	}
	
	|Str matched, Obj? ctx| pushAction(Str type, Obj? data := null) {
		|Str matched, TreeCtx ctx| { ctx.push(type, matched, data) }
	}

	|Str matched, Obj? ctx| addAction(Str type, Obj? data := null) {
		|Str matched, TreeCtx ctx| { ctx.current.add(type, matched, data) }
	}

	|Str matched, Obj? ctx| popAction(Str? type := null) {
		|Str matched, TreeCtx ctx| { ctx.pop(type) }
	}
}


@Js
class TreeCtx {
	TreeItem[]	items	:= TreeItem[TreeItem("root")]

	TreeItem current	:= items.first
	
	This push(Str type, Str? matched := null, Obj? data := null) {
		item := TreeItem(type, matched, data)
		item.parent = current
		current.items = current.items.rw.add(item)
		current = item
		return this
	}

	This pop(Str? type := null) {
		// TODO: add some err handling and proper msgs should we not find what we're looking for
		if (type != null)
			while (current.type != type)
				current = current.parent
		current = current.parent
		return this
	}

	TreeItem root() {
		if (items.isEmpty)
			throw Err("Too many pops! List is empty.")
		return items.first
	}
	
	override Str toStr() {
		items.join("\n")
	}
}

@Js
class TreeItem {
	TreeItem[]	items	:= TreeItem#.emptyList
	TreeItem?	parent
	Str			type
	Str?		matched
	Obj?		data

	internal new make(Str type, Str? matched := null, Obj? data := null) {
		this.type		= type
		this.matched	= matched
		this.data		= data
	}

	** Returns a sibling 'TreeItem' or 'null' if this is the first item in the list.
	TreeItem? prev() {
		idx := parent.items.findIndex { it === this }
		return idx == 0 ? null : parent.items.getSafe(idx - 1)
	}

	** Returns a sibling 'TreeItem' or 'null' if this is the last item in the list.
	TreeItem? next() {
		idx := parent.items.findIndex { it === this }
		return parent.items.getSafe(idx + 1)
	}

	** Creates and adds a 'TreeItem' to the end of the child items.
	** Returns the created 'TreeItem'.
	TreeItem add(Str type, Str? matched := null, Obj? data := null) {
		addItem(TreeItem(type, matched, data))
	}

	** Adds the 'TreeItem' to the end of the child items and sets the parent.
	** Returns the given 'TreeItem'.
	TreeItem addItem(TreeItem item) {
		item.parent = this
		items = items.rw.add(item)
		return item
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
