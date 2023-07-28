extends ExtendedButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	state = Preferences.read_pref("gi")
	change_text()

func _pressed():
	state = (state + 1) % 5
	change_text()
	Preferences.write_pref("gi", state)
	graphics_controller.change_global_illumination(state)

func change_text():
	if state == 0:
		text = "DISABLED"
	elif state == 1:
		text = "LOW"
	elif state == 2:
		text = "MEDIUM"
	elif state == 3:
		text = "HIGH"
	elif state == 4:
		text = "ULTRA"
