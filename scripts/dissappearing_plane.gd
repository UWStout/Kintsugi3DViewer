extends Node3D

@export var camera : CameraRig
@export var distance_threshold : float = 2
@onready var csg_mesh_3d = $CSGMesh3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_mat = StandardMaterial3D.new()
	new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	new_mat.albedo_color = Color(0, 0, 0, 1)
	
	csg_mesh_3d.set_material(new_mat)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(camera.camera.global_position.y < global_position.y):
		return
	
	var dist_to_plane = camera.camera.global_position.y - global_position.y
	
	if dist_to_plane <= distance_threshold:
		var alpha = (dist_to_plane / distance_threshold)
		csg_mesh_3d.material.albedo_color = Color(0,0,0,alpha)
	else:
		csg_mesh_3d.material.albedo_color = Color(0,0,0,1)
