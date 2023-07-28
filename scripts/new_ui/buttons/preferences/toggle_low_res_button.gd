extends ToggleButton

func _ready():
	if Preferences.read_pref("low res only"):
		text = "ON"
		_is_toggled = true
	else:
		text = "OFF"

func _on_toggle_on():
	Preferences.write_pref("low res only", true)
	text = "ON"
	
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref("low res only", false)
	text = "OFF"
	
	super._on_toggle_off()
