extends ColorPicker

@export var movable_lights_controller : MovableLightingController

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_color_changed(color):
	if not movable_lights_controller == null:
		if not movable_lights_controller.selected_new_widget == null:
			movable_lights_controller.selected_new_widget.change_color(color)
		pass
