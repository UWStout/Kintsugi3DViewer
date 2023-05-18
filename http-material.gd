extends ShaderMaterial
class_name HTTPMaterial

@export var serverURL = "http://127.0.0.1:3000/"

var _loading = false

# Called when the node enters the scene tree for the first time.
func load(parent : Node):
	if (!_loading): # only load once
		_loading = true
		
		# TODO could make this general purpose if these weren't hardcoded
		_requestTexture("diffuseMap", "diffuse.png", parent)
		_requestTexture("normalMap", "normal.png", parent)
		_requestTexture("specularMap", "specular.png", parent)
		_requestTexture("roughnessMap", "roughness.png", parent)
		_requestTexture("weights0123", "weights00-03.png", parent)
		_requestTexture("weights4567", "weights04-07.png", parent)
		_requestTextureFromCSV("basisFunctions", "basisFunctions.csv", parent)
	
# Request an image over HTTP, store it in a texture, and bind it to a shader uniform
func _requestTexture(shaderParameter, textureName, parent):
	var http_request = HTTPRequest.new()
	parent.add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			var tex = _http_texture_request_completed(result, response_code, headers, body)
			self.set_shader_parameter(shaderParameter, tex))
	var error = http_request.request(serverURL + textureName)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
# Request an CSV file over HTTP, convert it to a texture, and bind it to a shader uniform
func _requestTextureFromCSV(shaderParameter, textureName, parent):
	var http_request = HTTPRequest.new()
	parent.add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			var tex = _http_csv_texture_request_completed(result, response_code, headers, body)
			self.set_shader_parameter(shaderParameter, tex))
	var error = http_request.request(serverURL + textureName)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
# Called when the HTTP request is completed.
# Loads the content as an image and stores it in a texture
func _http_texture_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded.")

	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var tex = ImageTexture.create_from_image(image)
	return tex
	
	
# Called when the HTTP request is completed.
# Processes the content as a CSV file and stores it in a texture
func _http_csv_texture_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("CSV file couldn't be downloaded.")

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
	return texture
