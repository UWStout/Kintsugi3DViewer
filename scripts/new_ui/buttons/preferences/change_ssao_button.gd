extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	select(Preferences.read_pref("ssao"))
	graphics_controller.change_ssao(Preferences.read_pref("ssao"))

func _on_item_selected(index):
	Preferences.write_pref("ssao", index)
	graphics_controller.change_ssao(index)
