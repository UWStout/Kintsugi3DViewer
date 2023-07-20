class_name ExpandContextMenuButton extends ExclusiveToggleButton

@export var context_name : String
@export var context_menu : ExpandingContextPanel

func _pressed():
	if context_menu.is_animating():
		return
	
	super._pressed()

func _on_toggle_on():
	await context_menu.expand_context(context_name)

func _on_toggle_off():
	await context_menu.shrink()
