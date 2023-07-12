extends ResourceFetcherChain

# Overload _init from ResourceFetcherChain to have 0 parameters
func _init():
	pass


# Set up the Resource Fetcher chain at runtime
# TODO: Read configurations to disable/enable cache and optimize the resource
# pipeline for the current device at runtime
func _ready():
	var http_fetcher = preload("res://scripts/resources/http_json_resource_fetcher.gd").new()
	http_fetcher.name = "HTTP Fetcher"
	var cache_fetcher = CachedResourceFetcher.new(http_fetcher)
	cache_fetcher.name = "Cache Fetcher"
	_child_fetcher = cache_fetcher
	add_child(http_fetcher)
	add_child(cache_fetcher)
