extends ExtendedButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	state = Preferences.read_pref("subsurface scattering")
	change_text()



func _pressed():
	state = (state + 1) % 4
	change_text()
	Preferences.write_pref("subsurface scattering", state)
	graphics_controller.change_subsurface_scattering(state)

func change_text():
	if state == 0:
		text = "DISABLED"
	elif state == 1:
		text = "LOW"
	elif state == 2:
		text = "MEDIUM"
	elif state == 3:
		text = "HIGH"
