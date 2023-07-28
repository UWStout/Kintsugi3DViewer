extends ExtendedButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	state = Preferences.read_pref("shadows")
	change_text()

func _pressed():
	state = (state + 1) % 6
	if state == 1:
		state = 2
	
	change_text()
	Preferences.write_pref("shadows", state)
	graphics_controller.change_shadows(state)

func change_text():
	if state == 0:
		text = "HARD"
	elif state == 2:
		text = "SOFT LOW"
	elif state == 3:
		text = "SOFT MEDIUM"
	elif state == 4:
		text = "SOFT HIGH"
	elif state == 5:
		text = "SOFT ULTRA"
