extends ExtendedButton

@export var settings_menu : Control

func _pressed():
	settings_menu.visible = false
	settings_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#CacheManager.reduce_cache(CacheManager.cache_mode)
