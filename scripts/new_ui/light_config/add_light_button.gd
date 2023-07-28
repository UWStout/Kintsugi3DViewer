extends Button

@export var environment_controller : EnvironmentController
@export var light_selection_ui : LightSelectionUI

func _pressed():
	var light = environment_controller.add_light_to_scene()
	
	if light == null:
		return
	
	light_selection_ui.create_button_for_light(light)
