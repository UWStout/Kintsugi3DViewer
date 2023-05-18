extends Node3D

@export var material : HTTPMaterial
@export var externalServer = true
@export var serverURL = "http://127.0.0.1:3000/"
@export var gltfFilename = "guan-yu.glb"

# Called when the node enters the scene tree for the first time.
func _ready():
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false # causes problems on itch.io, for example
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	if (externalServer):
		var error = http_request.request(serverURL + gltfFilename)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	else:
		# URL assumed to be relative to host URL
		var fullURL = RelativeToAbsoluteURL.convert(gltfFilename)
		
		var error = http_request.request(fullURL)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
		
	# start loading the textures too
	material.load(self)

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("GLTF couldn't be downloaded.  Error code: " + str(result))
	else:
		var doc = GLTFDocument.new()
		var gltf = GLTFState.new()
		doc.append_from_buffer(body, "", gltf) # transfer scene from body to gltf
		var scene = doc.generate_scene(gltf)
		add_child(scene) # add the GLTF scene as a child of this node
		var mesh = scene.get_child(0, true)
		mesh.set_surface_override_material(0, material)
