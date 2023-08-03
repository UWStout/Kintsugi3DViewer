extends ExtendedButton

@export var confirmation_panel : ConfirmationPanel

func _pressed():
	if not CacheManager.is_empty():
		confirmation_panel.prompt_confirmation("CLEAR LOCAL DATA", "This will clear ALL objects from the cache, including favorites. This cannot be undone", canceled, clear_cache)

func clear_cache():
	CacheManager.clear_cache()

func canceled():
	pass
