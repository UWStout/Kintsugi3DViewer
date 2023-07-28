extends ExtendedButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	state = Preferences.read_pref("ssao")
	change_text()

func _pressed():
	state = (state + 1) % 5
	change_text()
	Preferences.write_pref("ssao", state)
	graphics_controller.change_ssao(state)

func change_text():
	if state == 0:
		text = "VERY LOW"
	elif state == 1:
		text = "LOW"
	elif state == 2:
		text = "MEDIUM"
	elif state == 3:
		text = "HIGH"
	elif state == 4:
		text = "ULTRA"
