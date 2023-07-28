extends ExtendedButton

@export var settings_menu : Control

func _pressed():
	settings_menu.visible = true
	settings_menu.mouse_filter = Control.MOUSE_FILTER_STOP
