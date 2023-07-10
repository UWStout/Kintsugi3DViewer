extends Node
class_name RemoteGltfTexture

signal load_complete
signal texture_loaded(texture_name: String)

var _material: RemoteGltfMaterial
var _texture: Dictionary
var _shader_key: String

var texture_format: Image.Format = Image.FORMAT_RGBA8

func _init(p_material: RemoteGltfMaterial, p_texture: Dictionary, p_shader_key: String):
	_material = p_material
	_texture = p_texture
	_shader_key = p_shader_key


func load():
	var image_index = _texture["source"]
	_load_image_from_index(image_index, func(img):
		img = _process_image(img, texture_format)
		_load_shader_image(img, _shader_key)
		load_complete.emit()
		texture_loaded.emit(_shader_key)
	)


func _load_image_from_index(image_index: int, callback: Callable):
	var image = _material._gltf.state.json["images"][image_index]
	if image.has("uri"):
		var uri = image["uri"]
		if uri.begins_with("data:"):
			# Base64 embedded image
			var image_data = _decode_b64_image(uri)
			callback.call(image_data)
		else:
			# External image on server
			uri = _format_gltf_relative_uri(uri)
			_material._fetcher.fetch_image_callback(uri, callback)
	elif image.has("bufferView"):
		# Image in buffer
		var image_data = _decode_buffer_image(_material._gltf.state.json["bufferViews"][image["bufferView"]], image)
		callback.call(image_data)
	else:
		push_error("Image at index %s could not be decoded: No uri or bufferView!" % image_index)


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


func _process_image(image: Image, format) -> Image:
	image.generate_mipmaps()
	image.convert(format)
	return image


func _load_shader_image(image: Image, shaderKey: String):
	var texture := ImageTexture.create_from_image(image)
	_material.set_shader_parameter(shaderKey, texture)
