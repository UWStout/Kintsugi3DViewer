extends MarginContainer

func _ready():
	if not OS.get_name() == "Android" and not OS.get_name() == "iOS":
		return
	
	var safe_area = DisplayServer.get_display_safe_area()
	
	var screen_width = DisplayServer.screen_get_size().x
	var screen_height = DisplayServer.screen_get_size().y
	
	var scale_factor = screen_width / DisplayServer.window_get_size().x
	
	add_theme_constant_override("margin_top", safe_area.position.y * scale_factor)
	add_theme_constant_override("margin_left", safe_area.position.x * scale_factor)
	add_theme_constant_override("margin_bottom", (screen_height - safe_area.size.y) * scale_factor)
	add_theme_constant_override("margin_right", (screen_width - safe_area.size.x) * scale_factor)

