extends ColorPicker

class_name LightColorPicker

@export var environment_controller : EnvironmentController

func _on_color_changed(color):
	if not environment_controller == null:
		if not environment_controller.selected_light == null:
			environment_controller.selected_light.change_color(color)
