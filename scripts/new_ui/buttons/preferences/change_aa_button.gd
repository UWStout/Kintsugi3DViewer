extends OptionButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	select(Preferences.read_pref("aa"))
	graphics_controller.change_antialiasing(Preferences.read_pref("aa"))

func _on_item_selected(index):
	Preferences.write_pref("aa", index)
	graphics_controller.change_antialiasing(index)
