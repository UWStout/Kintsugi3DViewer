extends Node3D

@export var artifact_name : String = "Unnamed Artifact"
@export var artifact_description : String = "No Description Available"

@export var artifact_model : Node3D
@export var annotations : Array[NodePath]

func select_artifact():
	for annotation_node_path in annotations:
		var annotation_marker = get_node(annotation_node_path)
		AnnotationsManager.register_new_annotation(annotation_marker)
		annotation_marker.collision_layer = 2
	pass

func deselect_artifact():
	AnnotationsManager.change_selected_annotation(null)
	AnnotationsManager.clear_annotations_array()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
