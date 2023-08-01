extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	select(Preferences.read_pref("gi"))
	graphics_controller.change_global_illumination(Preferences.read_pref("gi"))

func _on_item_selected(index):
	Preferences.write_pref("gi", index)
	graphics_controller.change_global_illumination(index)
