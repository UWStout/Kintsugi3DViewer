extends ToggleButton

@onready var cache_artifact_display = $"../../../.."

func _on_toggle_on():
	CacheManager.make_persistent(cache_artifact_display.artifact_url_name)
	
	super._on_toggle_on()

func _on_toggle_off():
	CacheManager.make_not_persistent(cache_artifact_display.artifact_url_name)
	
	super._on_toggle_off()
