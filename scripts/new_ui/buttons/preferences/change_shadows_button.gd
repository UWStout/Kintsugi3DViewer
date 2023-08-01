extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	var state = Preferences.read_pref("shadows")
	if state > 0:
		state = state - 1
	select(state)
	graphics_controller.change_shadows(state)

func _on_item_selected(index):
	var state = index
	if index > 0:
		state = state + 1
	Preferences.write_pref("shadows", state)
	graphics_controller.change_shadows(state)
