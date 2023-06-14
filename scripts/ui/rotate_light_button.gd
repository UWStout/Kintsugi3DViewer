extends HSlider

class_name RotateLightsButton

@export var connected_moving_lights_controller : MovableLightingController

func _ready():
	if not connected_moving_lights_controller == null:
		connected_moving_lights_controller.slider_button = self

func enable_slider():
	visible = true
	if not connected_moving_lights_controller.selected_light == null:
		value = connected_moving_lights_controller.selected_light.angle
	
func disable_slider():
	visible = false

func _on_value_changed(value):
	if not connected_moving_lights_controller == null:
		if not connected_moving_lights_controller.selected_light == null:
			connected_moving_lights_controller.selected_light.update_angle(value)
