extends OptionButton

class_name SelectEnvironmentButton

var connected_controller : EnvironmentController

func _on_item_selected(index):
	connected_controller.open_scene(index)
	pass # Replace with function body.
