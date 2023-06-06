extends Node3D

class_name ArtifactsController

@export var artifacts : Array[NodePath]

var current_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	current_index = 0
	if not artifacts.size() < 0 and not current_index >= artifacts.size() and not artifacts[0] == null:
		(get_node(artifacts[0]) as Node3D).visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display_artifact(index : int):
	if not current_index < 0 and not current_index >= artifacts.size() and not artifacts[current_index] == null:
		(get_node(artifacts[current_index]) as Node3D).visible = false
	
	if not index < 0 and not index >= artifacts.size() and not artifacts[index] == null:
			(get_node(artifacts[index]) as Node3D).visible = true

	current_index = index

func display_next_artifact():
	var new_index = (current_index + 1) % artifacts.size()
	display_artifact(new_index)

func display_previous_artifact():
	var new_index = (current_index - 1) % artifacts.size()
	if(new_index < 0):
		new_index = artifacts.size()-1
	display_artifact(new_index)

func display_this_artifact(artifact_node_path : NodePath):
	var string_name := artifact_node_path.get_name(artifact_node_path.get_name_count() - 1)
	var search_path := NodePath(string_name)
	display_artifact(artifacts.find(search_path))
