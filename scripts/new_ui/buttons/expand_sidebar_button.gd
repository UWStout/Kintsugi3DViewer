class_name ExpandSiderbarButton extends ExclusiveToggleButton

@export var sidebar_selection_menu : SidebarSelectionMenu

func _pressed():
	if sidebar_selection_menu._expanding or sidebar_selection_menu._shrinking:
		return
	
	super._pressed()

func _on_toggle_on():
	sidebar_selection_menu.expand_sidebar()

func _on_toggle_off():
	sidebar_selection_menu.shrink_sidebar()
