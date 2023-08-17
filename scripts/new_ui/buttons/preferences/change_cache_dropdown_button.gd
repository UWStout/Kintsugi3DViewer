extends DropdownButton

func _ready():
	selected_index = CacheManager.cache_mode
	
	super._ready()

func on_select_option(index : int):
	CacheManager.set_cache_mode(index)
	
	super.on_select_option(index)
