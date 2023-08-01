extends ExtendedButton

@export var confirmation_panel : ConfirmationPanel

func _pressed():
	if not CacheManager.is_empty():
		confirmation_panel.prompt_confirmation("CLEAR CACHE", "You will not be able to recover it", canceled, clear_cache)

func clear_cache():
	CacheManager.clear_cache()

func canceled():
	pass
