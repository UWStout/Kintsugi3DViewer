extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	select(Preferences.read_pref("subsurface scattering"))
	graphics_controller.change_subsurface_scattering(Preferences.read_pref("gi"))

func _on_item_selected(index):
	Preferences.write_pref("subsurface scattering", index)
	graphics_controller.change_subsurface_scattering(index)
