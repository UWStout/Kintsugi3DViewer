extends Node3D

@onready var artifact_catalog = ArtifactCatalog
@onready var load_from_gltf = preload("res://load-from-gltf.gd")

func _ready():
	artifact_catalog.artifacts_loaded.connect(_on_artifacts_loaded)

func _on_artifacts_loaded(artifacts: Array[ArtifactData]):
	var modelartifact: ArtifactData
	for artifact in artifacts:
		if artifact.gltfUrl != "":
			modelartifact = artifact
			break
	
	var model = load_from_gltf.new()
	model.material = HTTPMaterial.new()
	model.serverURL = modelartifact.gltfUrl
	model.gltfFilename = ""
	model.externalServer = true
	add_child(model)
