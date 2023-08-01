extends OnOffButton

@export var artifact_catalog_ui : ArtifactCatalogUI

func _ready():
	var pref = Preferences.read_pref("offline mode")
	if not pref == null and pref is bool:
		_start_toggled = pref
	
	super._ready()

func _on_toggle_on():
	Preferences.write_pref("offline mode", true)
	if not artifact_catalog_ui == null:
		artifact_catalog_ui.refresh_list()
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref("offline mode", false)
	if not artifact_catalog_ui == null:
		artifact_catalog_ui.refresh_list()
	super._on_toggle_off()
