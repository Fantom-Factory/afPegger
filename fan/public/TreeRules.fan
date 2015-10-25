
** Rules and actions for creating tree structures.  
@Js
class TreeRules : Rules {

	** Creates and pushes a 'TreeItem' onto the tree. 
	Rule push(Str type, Obj? data := null) {
		doAction(pushAction(type, data))
	}
	
	** Creates and adds a 'TreeItem' onto the tree. 
	Rule add(Str type, Obj? data := null) {
		doAction(addAction(type, data))
	}
	
	** Pops the last 'TreeItem' off the tree. 
	Rule pop(Str? type := null) {
		doAction(popAction(type))
	}
	
	** Creates and pushes a 'TreeItem' onto the tree. 
	|Str matched, Obj? ctx| pushAction(Str type, Obj? data := null) {
		|Str matched, TreeCtx ctx| { ctx.push(type, matched, data) }
	}

	** Creates and adds a 'TreeItem' onto the tree. 
	|Str matched, Obj? ctx| addAction(Str type, Obj? data := null) {
		|Str matched, TreeCtx ctx| { ctx.current.add(type, matched, data) }
	}

	** Pops the last 'TreeItem' off the tree. 
	|Str matched, Obj? ctx| popAction(Str? type := null) {
		|Str matched, TreeCtx ctx| { ctx.pop(type) }
	}
}

** The 'ctx' object that holds the tree structure. Is created with an initial 'root' element
@Js
class TreeCtx {
	TreeItem[]	items	:= TreeItem[TreeItem("root")]

	** Returns the *current* tree item. This is set by 'push()' and 'pop()'.
	TreeItem current	:= items.first
	
	** Creates a 'TreeItem' adding it as a child and setting it to current.
	This push(Str type, Str? matched := null, Obj? data := null) {
//		echo("pushing $type")
		item := TreeItem(type, matched, data)
		item.parent = current
		current.items = current.items.rw.add(item)
		current = item
		return this
	}

	** Pops the last 'TreeItem' off the stack. 
	** If 'type' is non-null then item are repeatedly popped until the last popped item was of the same type. 
	This pop(Str? type := null) {
//		echo("popping ${current.type}")
		// TODO: add some err handling and proper msgs should we not find what we're looking for
		if (type != null)
			while (current.type != type)
				current = current.parent
		current = current.parent
		return this
	}

	** Returns the root item.
	TreeItem root() {
		if (items.isEmpty)
			throw Err("Too many pops! List is empty.")
		return items.first
	}
	
	** Prints the tree structure.
	override Str toStr() {
		items.join("\n")
	}
}

** Represents an item in a tree structure.
@Js
class TreeItem {
	** The child items.
	TreeItem[]	items	:= TreeItem#.emptyList
	
	** The parent item.
	TreeItem?	parent
	
	** The item type.
	Str			type
	
	** Any character data matched to this item.
	Str?		matched
	
	** User data.
	Obj?		data

	internal new make(Str type, Str? matched := null, Obj? data := null) {
		this.type		= type
		this.matched	= matched
		this.data		= data
	}

	** Returns a sibling 'TreeItem' or 'null' if this is the first item in the list.
	TreeItem? prev() {
		idx := parent?.items?.findIndex { it === this } ?: 0
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

	** Walks this item and it's children, calling the given funcs when entering and exiting.
	Void walk(|TreeItem|? enter, |TreeItem|? exit) {
		enter?.call(this)
		items.each { it.walk(enter, exit) }
		exit?.call(this)
	}
	
	** Prints the tree structure.
	override Str toStr() {
		str := type + ":" + (data ?: "") + ":" + (matched?.toCode(null) ?: "")
		if (items.size > 0)
			str += "\n" + items.join("\n").splitLines.map { "    ${it}" }.join("\n")
		return str
	}
}
