extends ImageTexture
class_name HTTPImageTexture

@export var url: String
@export var resize_width: int = 128
@export var resize_height: int = 128

func _ready():
	print("ready called")

func set_url(new_url: String):
	url = new_url
	
func load(parent: Node):
	var req = HTTPRequest.new()
	parent.add_child(req)
	req.connect("request_completed", _http_request_complete)
	var request_status = req.request(url)
	if request_status != OK:
		push_error("Error occured attempting to load ImageTexture from HTTP source. Parent node: %s" % parent.get_path())

func _http_request_complete(result, respose_code, headers, body):
	var image = Image.new()
	
	var type: String
	for header in headers:
		if header.begins_with("Content-Type: "):
			type = header.get_slice(" ", 1)
	
	match type:
		"image/jpeg":
			image.load_jpg_from_buffer(body)
		"image/png":
			image.load_png_from_buffer(body)
		"image/webp":
			image.load_webp_from_buffer(body)
		_:
			push_error("Unrecognized image format received from server: '%s'" % type)
			return
	
	image.resize(resize_width, resize_height)
	set_image(image)
