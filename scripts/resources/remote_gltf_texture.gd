extends Node
class_name RemoteGltfTexture

signal load_complete
signal texture_loaded(texture_name: String)

var _material: RemoteGltfMaterial
var _texture: Dictionary
var _shader_key: String

var texture_format: Image.Format = Image.FORMAT_RGBA8

enum ImageSource {
	EXTERNAL,
	BASE64,
	BUFFER,
	ERROR,
}

func _init(p_material: RemoteGltfMaterial, p_texture: Dictionary, p_shader_key: String):
	_material = p_material
	_texture = p_texture
	_shader_key = p_shader_key
	name = p_shader_key


func load():
	if _texture.has("extras") and _texture["extras"].has("lods"):
		# Check if the highest resolution texture needs to be transmitted
		# i.e. not in the gltf (already loaded) or in the cache (if enabled)(quicker to load)
		var full_image = _image_at_index(_texture["source"])
		if not _image_needs_remote_load(full_image):
			_load_image(full_image)
			return
		
		if _texture["extras"]["lods"].has("128"):
			print("Loading 128px resolution for %s" % _shader_key)
			_load_image(_image_at_index(_texture["extras"]["lods"]["128"]))
	else:
		_load_image(_image_at_index(_texture["source"]))


func _image_needs_remote_load(image: Dictionary) -> bool:
	var cache: CachedResourceFetcher
	var chain := (_material._fetcher as ResourceFetcherChain)
	if is_instance_valid(chain):
		cache = chain.get_fetcher_by_type(CachedResourceFetcher)
	
	if _image_source(image) != ImageSource.EXTERNAL:
		return false
	elif is_instance_valid(cache) and cache.is_image_cached(_format_gltf_relative_uri(image["uri"])):
		return false
	
	return true

func _load_image(image: Dictionary, callback: Callable = _load_shader_image):
	var type := _image_source(image)
	
	match type:
		ImageSource.EXTERNAL:
			_material._fetcher.fetch_image_callback(_format_gltf_relative_uri(image["uri"]), callback)
		ImageSource.BASE64:
			callback.call(_decode_b64_image(image["uri"]))
		ImageSource.BUFFER:
			var image_data = _decode_buffer_image(_material._gltf.state.json["bufferViews"][image["bufferView"]], image)
			callback.call(image_data)
		_:
			push_error("Image could not be decoded: No uri or bufferView!\n%s" % image)


func _image_source(image: Dictionary) -> ImageSource:
	if image.has("uri"):
		var uri = image["uri"]
		if uri.begins_with("data:"):
			return ImageSource.BASE64
		else:
			return ImageSource.EXTERNAL
	elif image.has("bufferView"):
		return ImageSource.BUFFER
	else:
		return ImageSource.ERROR


func _image_at_index(index: int) -> Dictionary:
	return _material._gltf.state.json["images"][index]


# TODO: Not working yet
func _decode_buffer_image(bufferView: Dictionary, p_image: Dictionary) -> Image:
	print(bufferView)
	var buffer = _material._gltf.state.json["buffers"][bufferView["buffer"]]
	var data = Marshalls.base64_to_raw(buffer["uri"].get_slice(',', 1))
	
	var start = 0
	if bufferView.has("byteOffset"):
		start = bufferView["byteOffset"]
	var end = start + bufferView["byteLength"]
	
	var viewData = data.slice(start, end)
	
	var o_image = Image.new()
	match p_image["mimeType"]:
		"image/jpeg":
			o_image.load_jpg_from_buffer(data)
		"image/png":
			o_image.load_png_from_buffer(data)
		"image/webp":
			o_image.load_webp_from_buffer(data)
		_:
			push_error("Unrecognized image format received from server: '%s'" % p_image["mimeType"])
	
	return o_image


# TODO: Not implemented
func _decode_b64_image(uri: String) -> Image:
	print(uri)
	return Image.new()


func _format_gltf_relative_uri(uri: String) -> String:
	var folder = _material._gltf.sourceUri.get_base_dir()
	return folder.path_join(uri)


func _process_image(image: Image) -> Image:
	image.generate_mipmaps()
	image.convert(texture_format)
	return image


func _load_shader_image(image: Image):
	var texture := ImageTexture.create_from_image(image)
	_material.set_shader_parameter(_shader_key, texture)
	load_complete.emit()
	texture_loaded.emit(_shader_key)