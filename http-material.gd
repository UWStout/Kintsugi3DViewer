extends ShaderMaterial
class_name HTTPMaterial

@export var externalServer = true
@export var serverURL = "http://127.0.0.1:3000/"

var _loading = false

# Called when the node enters the scene tree for the first time.
func load(parent : Node):
	if (!_loading): # only load once
		_loading = true
		
		# TODO could make this general purpose if these weren't hardcoded
		_requestTexture("diffuseMap", "diffuse.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_SRGB)
			img.convert(Image.FORMAT_RGB8) 	# Workaround to get a little bit of compression
											# TODO: Figure out why normal compression doesn't work on the web	
			print("diffuse: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTexture("normalMap", "normal.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_NORMAL)
			img.convert(Image.FORMAT_RG8)
			print("normal: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTexture("specularMap", "specular.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_SRGB)
			img.convert(Image.FORMAT_RGB8)
			print("specular: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTexture("roughnessMap", "roughness.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress_from_channels(Image.COMPRESS_S3TC, Image.USED_CHANNELS_R)
			img.convert(Image.FORMAT_R8)
			print("roughness: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTexture("weights0123", "weights00-03.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress_from_channels(Image.COMPRESS_S3TC, Image.USED_CHANNELS_RGBA)
			print("weights0123: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTexture("weights4567", "weights04-07.png", parent, func(img):
			img.generate_mipmaps() # need to generate mipmaps before compressing
#			img.compress_from_channels(Image.COMPRESS_S3TC, Image.USED_CHANNELS_RGBA)
			print("weights4567: " + str(img.get_format()))
			return ImageTexture.create_from_image(img))
		_requestTextureFromCSV("basisFunctions", "basisFunctions.csv", parent)
	
# Request an image over HTTP, store it in a texture, and bind it to a shader uniform
func _requestTexture(shaderParameter, textureName, parent, processFunction):
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false # causes problems on itch.io, for example
	parent.add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			var img = _http_texture_request_completed(result, response_code, headers, body)
			var tex = processFunction.call(img)
			self.set_shader_parameter(shaderParameter, tex))
			
	if (externalServer):
		var error = http_request.request(serverURL + textureName)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	else:
		# URL assumed to be relative to host URL
		var fullURL = RelativeToAbsoluteURL.convert(textureName)
		var error = http_request.request(fullURL)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
		
# Request an CSV file over HTTP, convert it to a texture, and bind it to a shader uniform
func _requestTextureFromCSV(shaderParameter, csvFilename, parent):
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false # causes problems on itch.io, for example
	parent.add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			var tex = _http_csv_texture_request_completed(result, response_code, headers, body)
			self.set_shader_parameter(shaderParameter, tex))
	if (externalServer):
		var error = http_request.request(serverURL + csvFilename)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	else:
		# URL assumed to be relative to host URL
		var fullURL = RelativeToAbsoluteURL.convert(csvFilename)
		var error = http_request.request(fullURL)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	
# Called when the HTTP request is completed.
# Loads the content as an image and stores it in a texture
func _http_texture_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded.  Error code: " + str(result))
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
	return image
	
# Called when the HTTP request is completed.
# Processes the content as a CSV file and stores it in a texture
func _http_csv_texture_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("CSV file couldn't be downloaded.  Error code: " + str(result))
		return null
	else:
		var tex = _csv_to_texture(body.get_string_from_utf8())
		return tex

func _csv_to_texture(body : String):
	var width = 0;
	var data = PackedFloat32Array()
	
	var lines = body.split('\n')
	var count = lines.size() / 3
	
	for k in range(0, count * 3, 3): # process lines in groups of 3
		var red = lines[k].split(',')
		var green = lines[k + 1].split(',')
		var blue = lines[k + 2].split(',')
		
		if (width == 0):
			width = red.size() - 1 # red, green, blue must all have the same length
			# ignore the first element of every line, which is just the row header
		
		if (red.size() >= 2):
			for i in width: 
				data.append(float(red[i + 1]))
				data.append(float(green[i + 1]))
				data.append(float(blue[i + 1]))
	
	var img = Image.create_from_data(width, count, false, Image.FORMAT_RGBF, data.to_byte_array())
	print(img.get_width())
	print(img.get_height())
	var texture = ImageTexture.create_from_image(img)
	print(img.get_format())
	print(texture.get_format())
	return texture
