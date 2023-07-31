extends OnOffButton

@export var preference_name : String

func _ready():
	var pref = Preferences.read_pref(preference_name)
	if not pref == null and pref is bool:
		_start_toggled = Preferences.read_pref(preference_name)
	
	super._ready()

func _on_toggle_on():
	Preferences.write_pref(preference_name, true)
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref(preference_name, false)
	super._on_toggle_off()
