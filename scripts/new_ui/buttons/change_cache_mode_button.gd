extends ExtendedButton

var state : int = 0

func _ready():
	state = Preferences.read_pref("cache mode")
	change_button_text()

func _pressed():
	state = (state + 1) % 4
	change_button_text()
	Preferences.write_pref("cache mode", state)

func change_button_text():
	if state == 0:
		text = "LARGEST"
	elif state == 1:
		text = "SMALLEST"
	elif state == 2:
		text = "MOST RECENT"
	elif state == 3:
		text = "LEAST RECENT"
