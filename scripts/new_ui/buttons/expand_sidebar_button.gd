class_name ExpandSiderbarButton extends ExclusiveToggleButton

@onready var texture_rect = $CenterContainer/TextureRect

var toggled_on_icon = preload("res://assets/ui/UI_V2/FlyoutSide_V2/FlyoutSide_In_V2.svg")
var toggled_off_icon = preload("res://assets/ui/UI_V2/FlyoutSide_V2/FlyoutSide_Out_V2.svg")


@export var sidebar_selection_menu : SidebarSelectionMenu

func _pressed():
	if sidebar_selection_menu._expanding or sidebar_selection_menu._shrinking:
		return
	
	super._pressed()

func _on_toggle_on():
	sidebar_selection_menu.expand_sidebar()
	
	super._on_toggle_on()

func _on_toggle_off():
	sidebar_selection_menu.shrink_sidebar()
	
	super._on_toggle_off()

func _display_toggled_on():
	texture_rect.texture = toggled_on_icon
	super._display_toggled_on()

func _display_toggled_off():
	texture_rect.texture = toggled_off_icon
	super._display_toggled_off()
