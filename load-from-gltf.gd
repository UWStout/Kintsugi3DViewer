extends Node3D

@export var material : HTTPMaterial
@export var gltfURL = "http://127.0.0.1:3000/guan-yu.glb"

# Called when the node enters the scene tree for the first time.
func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	var error = http_request.request(gltfURL)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	# start loading the textures too
	material.load(self)

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("GLTF couldn't be downloaded.")
	var doc = GLTFDocument.new()
	var gltf = GLTFState.new()
	doc.append_from_buffer(body, "", gltf) # transfer scene from body to gltf
	var scene = doc.generate_scene(gltf)
	add_child(scene) # add the GLTF scene as a child of this node
	var mesh = scene.get_child(0, true)
	mesh.set_surface_override_material(0, material)
