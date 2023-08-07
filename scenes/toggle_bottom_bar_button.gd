extends ExclusiveToggleButton

@onready var texture_rect = $CenterContainer/TextureRect

var toggled_on_icon = preload("res://assets/ui/UI_V2/FlyoutBottom_V2/FlyoutSide_In_V2.svg")
var toggled_off_icon = preload("res://assets/ui/UI_V2/FlyoutBottom_V2/FlyoutBot_Out_V2.svg")

@export var panel : ExpandingPanel

func _on_toggle_on():
	panel.expand()
	
	super._on_toggle_on()

func _on_toggle_off():
	panel.shrink()
	
	super._on_toggle_off()

func _display_toggled_on():
	texture_rect.texture = toggled_on_icon
	super._display_toggled_on()

func _display_toggled_off():
	texture_rect.texture = toggled_off_icon
	super._display_toggled_off()
