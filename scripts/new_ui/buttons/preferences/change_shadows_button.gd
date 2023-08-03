extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	var state = graphics_controller.shadows
	if state > 0:
		state = state - 1
	select(state)

func _on_item_selected(index):
	var state = index
	if index > 0:
		state = state + 1
	graphics_controller.change_shadows(state)
