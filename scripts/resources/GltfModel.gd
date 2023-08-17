class_name GltfModel extends Node3D

var is_local : bool = false

signal load_completed
signal load_progress(estimation : float)

@export var artifactGltfUrl : String

var artifact: ArtifactData = null
var load_finished : bool = false

func _load_gltf():
	pass

func _load_artifact() -> int:
	return 0
