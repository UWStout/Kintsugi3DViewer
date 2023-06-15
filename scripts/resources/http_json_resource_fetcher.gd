extends ResourceFetcher

#TODO: Temporary; idealy this should be fetched at runtime from some sort of user preferences object
var server_root: String = "http://jbuelow.com:3000/" # Test server
var index_filepath = "index.json"

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
		raw_data_cache = await _fetch_url_json(_format_relative_url(index_filepath))
		raw_data_cache_time = Time.get_ticks_msec()
	
	artifacts_cache = _parse_artifacts_data(raw_data_cache)
	return artifacts_cache


func fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	return await force_fetch_gltf(artifact)


func force_fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	var url = _format_relative_url(artifact.gltfUrl)
	var headers = PackedStringArray(["Accept: model/gltf-binary, model/gltf+json"])
	var raw_data = await _fetch_url_raw(url, headers)
	
	var document = GLTFDocument.new()
	var state = GLTFState.new()
	
	# 0x20 is used for flags to disable loading of textures and images, as
	# the godot glTF loader will by default try to find external resources during
	# the initial load process and is not euqipped to handle http resources, thus
	# causing the load to fail outright. See modules/gltf/gltf_document.cpp@69,7318,7364
	var gltf_error = document.append_from_buffer(raw_data, "", state, 0x20)
	
	if gltf_error:
		push_error("An error occured parsing glTF data! Error code: %s" % gltf_error)
		return GLTFObject.new()
	
	var object := GLTFObject.new()
	object.document = document
	object.state = state
	object.sourceUri = artifact.gltfUrl
	
	return object


func fetch_image(url: String) -> Image:
	return await force_fetch_image(url)


func force_fetch_image(url: String) -> Image:
	var image = Image.new()
	
	var request_headers = ["Accept: image/png, image/jpeg, image/webp"]
	var response = await _fetch_url_fullraw(_format_relative_url(url), request_headers)
	var data = response[3]
	var headers = response[2]
	
	var type: String
	for header in headers:
		if header.begins_with("Content-Type: "):
			type = header.get_slice(" ", 1)
	
	match type:
		"image/jpeg":
			image.load_jpg_from_buffer(data)
		"image/png":
			image.load_png_from_buffer(data)
		"image/webp":
			image.load_webp_from_buffer(data)
		_:
			push_error("Unrecognized image format received from server: '%s'" % type)
	
	return image


func _format_relative_url(url: String) -> String:
	return server_root + url


func _fetch_url_fullraw(url: String, request_headers := PackedStringArray()) -> Array:
	var request = HTTPRequest.new();
	add_child(request)
	
	# Check for client-side request errors (malformed urls, etc)
	var client_error = request.request(url, request_headers)
	if client_error != OK:
		push_error("A client-side error occoured requesting url: '%s'" % url)
		request.queue_free()
		return []
	
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
		return response
	
	# Check server status code
	if response_code != 200:
		push_error("Erorr fetching json data: Server returned a %s status code fetching url '%s'" % [response_code, url])
		request.queue_free()
		return response
	
	request.queue_free()
	return [result, response_code, headers, body]


func _fetch_url_raw(url: String, request_headers := PackedStringArray()) -> PackedByteArray:
	var response = await _fetch_url_fullraw(url, request_headers)
	return response[3]


# Fetches a url and attempts to parse JSON data from it.
# Is an awaitable corroutine.
func _fetch_url_json(url: String) -> Dictionary:
	var data = await _fetch_url_raw(url, PackedStringArray(["Accept: application/json"]))
	
	# Parse json and check for parse errors
	var json = JSON.new()
	var parse_error = json.parse(data.get_string_from_utf8())
	if parse_error != OK:
		push_error("An error occured parsing json retrieved from server: %s" % json.get_error_message())
		return {}
	
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
