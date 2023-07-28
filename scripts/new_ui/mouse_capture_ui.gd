extends Control

@export var hide_ui_button : HideUIButton
@export var top_dock : ExpandingPanel
@export var settings_menu : Control

var was_mouse_inside : bool = false
var was_mouse_outside : bool = false


func _ready():
	top_dock.is_expanded = true

func _input(event):
	match OS.get_name():
		"Windows", "UWP", "macOS", "Linux", "FreeBSD", "NetBSD", "openBSD", "BSD", "Web":
			pass
		_:
			return
	
	if event is InputEventMouseMotion:
		var pos = event.position as Vector2
		
		if pos.y <= 85:
			if not top_dock.is_expanded and hide_ui_button._is_toggled and not settings_menu.visible:
				top_dock.expand()
		else:
			if top_dock.is_expanded and hide_ui_button._is_toggled and not settings_menu.visible:
				top_dock.shrink()

