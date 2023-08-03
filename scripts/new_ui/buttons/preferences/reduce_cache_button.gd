extends Button

func _pressed():
	CacheManager.reduce_cache(CacheManager.cache_mode)
