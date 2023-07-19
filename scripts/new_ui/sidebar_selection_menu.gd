class_name SidebarSelectionMenu extends ExpandingPanel

@export var context_menu : ExpandingContextPanel

var was_context_expanded : bool = false

func expand_sidebar():
	await expand()
	
	if was_context_expanded:
		await context_menu.expand()

func shrink_sidebar():
	was_context_expanded = context_menu.is_expanded
	await context_menu.shrink()
	shrink()
