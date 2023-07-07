extends Node
class_name RemoteGltfTexture

signal load_complete
signal texture_loaded(texture_name: String)

var _fetcher: ResourceFetcher
var _gltf: GLTFObject
var _texture: Dictionary
var _material: ShaderMaterial

var texture_format: Image.Format = Image.FORMAT_RGBA8

func _init(p_fetcher: ResourceFetcher, p_gltf: GLTFObject, p_material: ShaderMaterial, p_texture: Dictionary):
	_fetcher = p_fetcher
	_gltf = p_gltf
	_texture = p_texture
	_material = p_material


func load(parameterKey: String):
	var image_index = _texture["index"]
	_load_image_from_index(image_index, func(img):
		img = _process_image(img, texture_format)
		_load_shader_image(img, parameterKey)
		load_complete.emit()
		texture_loaded.emit(parameterKey)
	)


func _load_image_from_index(image_index: int, callback: Callable):
	var image = _gltf.state.json["images"][image_index]
	if image.has("uri"):
		var uri = image["uri"]
		if uri.begins_with("data:"):
			# Base64 embedded image
			var image_data = _decode_b64_image(uri)
			callback.call(image_data)
		else:
			# External image on server
			uri = _format_gltf_relative_uri(uri)
			_fetcher.fetch_image_callback(uri, callback)
	elif image.has("bufferView"):
		# Image in buffer
		var image_data = _decode_buffer_image(_gltf.state.json["bufferViews"][image["bufferView"]], image)
		callback.call(image_data)
	else:
		push_error("Image at index %s could not be decoded: No uri or bufferView!" % image_index)


func _decode_buffer_image(bufferView: Dictionary, p_image: Dictionary) -> Image:
	print(bufferView)
	var buffer = _gltf.state.json["buffers"][bufferView["buffer"]]
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


func _decode_b64_image(uri: String) -> Image:
	print(uri)
	return Image.new()


func _format_gltf_relative_uri(uri: String) -> String:
	var folder = _gltf.sourceUri.get_base_dir()
	return folder.path_join(uri)


func _process_image(image: Image, format) -> Image:
	image.generate_mipmaps()
	image.convert(format)
	return image


func _load_shader_image(image: Image, shaderKey: String):
	var texture := ImageTexture.create_from_image(image)
	_material.set_shader_parameter(shaderKey, texture)
