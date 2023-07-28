extends ToggleButton

func _ready():
	if Preferences.read_pref("offline mode"):
		text = "ON"
		_is_toggled = true
	else:
		text = "OFF"

func _on_toggle_on():
	Preferences.write_pref("offline mode", true)
	text = "ON"
	
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref("offline mode", false)
	text = "OFF"
	
	super._on_toggle_off()
