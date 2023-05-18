extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_active_material(0).load(self) # assume active material is an HTTPMaterial
