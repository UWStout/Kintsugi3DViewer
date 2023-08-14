extends DropdownButton

func _ready():
	selected_option = CacheManager.cache_mode
	super._ready()

func on_option_selected(index : int):
	CacheManager.set_cache_mode(index)
