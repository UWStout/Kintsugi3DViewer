extends ExtendedButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	state = Preferences.read_pref("aa")

func _pressed():
	state = (state + 1) % 5
	change_text()
	Preferences.write_pref("aa", state)
	graphics_controller.change_antialiasing(state)
	

func change_text():
	if state == 0:
		text = "DISABLED"
	elif state == 1:
		text = "2x"
	elif state == 2:
		text = "4x"
	elif state == 3:
		text = "8x"
	elif state == 4:
		text = "MAX"
