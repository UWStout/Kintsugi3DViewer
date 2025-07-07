# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node3D
class_name ArtifactsController

signal artifacts_refreshed(artifacts: Array[ArtifactData])

signal artifact_changed(artifact: ArtifactData)

@export var _fetcher: ResourceFetcher
@export var _loader: ModelLoaderProgress

@export var _ibr_shader : Shader

@export var _environment_controller : EnvironmentController
@export var _artifact_catalog_ui : ArtifactCatalogUI

var current_index : int = 0
var artifacts: Array[ArtifactData]

var loaded_artifact: GltfModel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(_fetcher):
		_fetcher = GlobalFetcher
		if not is_instance_valid(_fetcher):
			push_error("Artifacts Controller at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	await refresh_artifacts()
	
	if UrlReader.parameters.has("artifact"):
		for artifact in artifacts:
			if UrlReader.parameters["artifact"] == artifact.gltfUri.get_base_dir():
				display_artifact_data(artifact)
	
	#print(OS.get_cmdline_args())
	
	var args = OS.get_cmdline_args()
	_open_artifact_through_file(args[0])
	#$"../new_ui_root/CenterContainer/Label".text += "\n" + arg
	
	#_open_artifact_through_file("C:\\Users\\BetanskiTyler\\test_directory\\guan-yu\\model.glb")

func refresh_artifacts() -> Array[ArtifactData]:
	if(Preferences.read_pref("offline mode")):
		artifacts = CacheManager.get_artifact_data()
	else:
		artifacts = await _fetcher.fetch_artifacts()
		artifacts_refreshed.emit(artifacts)
		
		if artifacts.size() == 0:
			artifacts = CacheManager.get_artifact_data()
	return artifacts


func display_artifact(index : int):
	if index < artifacts.size():
		display_artifact_data(artifacts[index])
	pass


func display_artifact_data(artifact: ArtifactData):
	if not loaded_artifact == null and artifact.name == loaded_artifact.artifact.name:
		return
	
	var artifact_index = artifacts.find(artifact)
	current_index = artifact_index
	
	if is_instance_valid(loaded_artifact):
		if not loaded_artifact.load_finished:
			loaded_artifact.stop_loading()
		
		loaded_artifact.queue_free()

	loaded_artifact = RemoteGltfModel.create(artifact)
	add_child(loaded_artifact)
	_on_model_begin_load()
	loaded_artifact.preview_load_completed.connect(_on_model_preview_load_complete)
	loaded_artifact.load_completed.connect(_on_model_load_complete)
	loaded_artifact.load_progress.connect(_on_model_load_progress)
	var result = await loaded_artifact.load_artifact()
	
	if result == 0:
		_on_model_begin_load()
		
		var button = _artifact_catalog_ui.get_button_for_artifact(artifact)
		if not button == null:
			if not button._is_toggled:
				button._pressed()
	else:
		if is_instance_valid(_loader):
			_loader.end_loading()

func display_remote_artifact_data(artifact : ArtifactData):
	pass

func display_local_artifact_data(artifact : ArtifactData):
	pass

func display_next_artifact():
	if loaded_artifact == null or not loaded_artifact.load_finished or loaded_artifact.is_local:
		return
	
	current_index = (current_index + 1) % artifacts.size()
	display_artifact(current_index)
	pass


func display_previous_artifact():
	if loaded_artifact == null or not loaded_artifact.load_finished or loaded_artifact.is_local:
		return
	
	current_index -= 1
	if current_index < 0:
		current_index = artifacts.size() - 1
	
	display_artifact(current_index)
	pass


func _on_model_begin_load():
	if is_instance_valid(_loader) and not loaded_artifact.load_finished:
		_loader.start_loading()
	
	#if loaded_artifact.load_finished:
		#_loader.end_loading()

func _place_artifact():
	var artifact_root = _environment_controller.get_active_artifact_root()
	if not artifact_root == null:
		var target_pos = _environment_controller.get_active_artifact_root().global_position
		#print(loaded_artifact.aabb.size.y)
		target_pos -= loaded_artifact.aabb.position # position relative to bounding box
		target_pos -= self.position # account for arbitrary position of artifacts controller node
		target_pos.x -= loaded_artifact.aabb.size.x / 2 # center x-axis
		target_pos.z -= loaded_artifact.aabb.size.z / 2 # center z-axis
		loaded_artifact.global_position = target_pos
		
func _on_model_preview_load_complete():
	_environment_controller.get_current_environment().set_artifact_bounds(loaded_artifact.aabb)
	_place_artifact()
	artifact_changed.emit(artifacts[current_index])
	
func _on_environment_changed(new_environment):
	if loaded_artifact != null:
		new_environment.set_artifact_bounds(loaded_artifact.aabb)
		_place_artifact()
		
func _on_model_load_complete():
	if is_instance_valid(_loader):
		_loader.end_loading()
	
	print("================== ARTIFACT LOAD COMPLETE =============================")
	#print("UPDATING OPEN TIME FOR ARTIFACT " + loaded_artifact.name)
	CacheManager.update_open_time(loaded_artifact.artifact.gltfUri.get_base_dir(), false)
	
	for button in _artifact_catalog_ui.get_buttons():
		if button.data.gltfUri == loaded_artifact.artifact.gltfUri:
			button._display_toggled_on()
		else:
			button._display_toggled_off()

func _on_model_load_progress(progress: float):
	if is_instance_valid(_loader):
		_loader.update_progress(progress)


func _look_for_mesh(node : Node3D):
	if node is MeshInstance3D:
		return node
	
	var children = node.get_children()
	var results = []
	
	for child in children:
		var child_result = _look_for_mesh(child)
		
		if not child_result == null:
			results.push_back(_look_for_mesh(child))
	
	if results.is_empty():
		return null
	else:
		return results.pop_front()


func _open_artifact_through_file(gltf_file_path : String):
	if not gltf_file_path.ends_with(".gltf") and not gltf_file_path.ends_with(".glb"):
		return
	
	if is_instance_valid(loaded_artifact):
		loaded_artifact.queue_free()
	
	var data = ArtifactData.new()
	data.gltfUri = gltf_file_path
	
	var model = LocalGltfModel.create(data)
	add_child(model)
	
	model.preview_load_completed.connect(_on_model_preview_load_complete)
	model.load_completed.connect(_on_model_load_complete)
	model.load_progress.connect(_on_model_load_progress)
	
	loaded_artifact = model # set here to prevent null pointer dereference
	model.load_artifact()
	
