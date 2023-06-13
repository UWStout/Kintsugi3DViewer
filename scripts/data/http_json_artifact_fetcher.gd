extends ArtifactFetcher

#TODO: Temporary; idealy this should be fetched at runtime from some sort of user preferences object
var data_source_url: String = "http://jbuelow.com:3000/index.json" # Test server

var raw_data_cache: Variant
@onready var raw_data_cache_time: int = cache_timeout_ms * -1

var artifacts_cache: Array[ArtifactData]
@onready var artifacts_cache_time: int = cache_timeout_ms * -1

var cache_timeout_ms: int = 120000

func _ready():
	var list = await fetch_artifacts()
	print("returned data: %s" % [list])
	print("raw data cache: %s" % [raw_data_cache])
	print("artifacts cache: %s" % [artifacts_cache])

func fetch_artifacts() -> Array[ArtifactData]:
	if artifacts_cache != null:
		if (Time.get_ticks_msec() - artifacts_cache_time) < cache_timeout_ms:
			# Cache is valid, return cached value
			return artifacts_cache
	# Cache is invalid or expired, refresh artifacts
	return await force_fetch_artifacts()

func force_fetch_artifacts() -> Array[ArtifactData]:
	# Refresh the raw data cache if necessary
	if (raw_data_cache == null
	or (Time.get_ticks_msec() - artifacts_cache_time) >= cache_timeout_ms):
		raw_data_cache = await _fetch_url_json(data_source_url)
		raw_data_cache_time = Time.get_ticks_msec()
	
	artifacts_cache = _parse_artifacts_data(raw_data_cache)
	return artifacts_cache

# Fetches a url and attempts to parse JSON data from it.
# Is an awaitable corroutine.
func _fetch_url_json(url: String) -> Dictionary:
	var request = HTTPRequest.new();
	add_child(request)
	
	# This function will only attempt to decode json data. Tell the server this!
	var request_headers = PackedStringArray(["Accept: application/json"])
	
	# Check for client-side request errors (malformed urls, etc)
	var client_error = request.request(url, request_headers)
	if client_error != OK:
		push_error("A client-side error occoured requesting json from url: '%s'" % url)
		request.queue_free()
		return {}
	
	# Wait for the request to complete and fetch signal parameters
	var response = await request.request_completed
	var result = response[0]
	var response_code = response[1]
	var headers = response[2]
	var body = response[3]
	
	# Check for transport errors (timed out, DNS failure, etc)
	if result != OK:
		push_error("An error occured while requesting json from url: '%s'" % url)
		request.queue_free()
		return {}
	
	# Check server status code
	if response_code != 200:
		push_error("Erorr fetching json data: Server returned a %s status code fetching url '%s'" % [response_code, url])
		request.queue_free()
		return {}
	
	# Parse json and check for parse errors
	var json = JSON.new()
	var parse_error = json.parse(body.get_string_from_utf8())
	if parse_error != OK:
		push_error("An error occured parsing json retrieved from server: %s" % json.get_error_message())
		request.queue_free()
		return {}
	
	# Return the parsed data and free the request node
	request.queue_free()
	return json.data

func _parse_artifacts_data(raw_data: Dictionary) -> Array[ArtifactData]:
	if raw_data == null:
		push_error("Failed to parse artifacts data: Raw data is invalid!")
		return []
	
	if not raw_data.has("artifacts"):
		push_error("Failed to parse artifacts data: No artifacts data block found!")
		return []
	
	var artifacts: Array[ArtifactData] = []
	for raw_artifact in raw_data.get("artifacts"):
		var artifact = ArtifactData.from_dict(raw_artifact)
		artifacts.append(artifact)
	
	return artifacts
