extends OptionButton

class_name SelectEnvironmentButton

@export var turntable_button : TurntableButton

var connected_controller : EnvironmentController

func _on_item_selected(index):
	connected_controller.open_scene(index)
	if not turntable_button == null:
		turntable_button.force_quit()
	pass # Replace with function body.
