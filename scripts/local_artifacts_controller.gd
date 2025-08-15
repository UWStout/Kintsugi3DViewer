class_name LocalArtifactsController extends ArtifactsController

@export var _save_import_panel : CenterContainer
@export var _save_import_button: Button
@export var _duplicate_model_popup : CenterContainer
@export var _overwrite_duplicate_button : Button

@export var _invalid_file_popup : CenterContainer


func _ready():
	assign_fetcher()
	
	await refresh_artifacts()
	
	
	var args = OS.get_cmdline_args()
	_open_artifact_through_file(args[0])

	#$"../new_ui_root/CenterContainer/Label".text += "\n" + arg
	
	#_open_artifact_through_file("C:\\Users\\BetanskiTyler\\test_directory\\guan-yu\\model.glb")
	
	
func refresh_artifacts() -> Array[ArtifactData]:
	artifacts = LocalSaveData.get_artifact_data()
	return artifacts

func _open_artifact_through_file(gltf_file_path : String):
	print("opening through file")
	if not gltf_file_path.ends_with(".gltf") and not gltf_file_path.ends_with(".glb"):
		return
	
	if is_instance_valid(loaded_artifact):
		loaded_artifact.queue_free()
	
	var data = ArtifactData.new()
	data.gltfUri = gltf_file_path
	
	var model = LocalGltfModel.create(data)
	add_child(model)
	#_on_model_begin_load()
	model.preview_load_completed.connect(_on_model_preview_load_complete)
	model.load_completed.connect(_on_model_load_complete)
	model.load_progress.connect(_on_model_load_progress)
	
	loaded_artifact = model # set here to prevent null pointer dereference
	model.load_artifact()
	print("model loaded")
	#after model loads, show prompt to name filepath
	_save_import_panel.visible = true
	_save_import_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var file_name = await _save_import_button.file_name_chosen
	print("name chosen")
	if file_name == "":
		file_name = (gltf_file_path.get_slice("/", (gltf_file_path.get_slice_count("/")-2)))
	_save_import_panel.visible = false
	_save_import_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#try to save new opened file
	#if duplicate file path is detected, show prompt to keep original or overwrite
	if not (LocalSaveData._save_model(file_name, gltf_file_path)):
		_duplicate_model_popup.visible = true
		_duplicate_model_popup.mouse_filter = Control.MOUSE_FILTER_STOP
		await _overwrite_duplicate_button.pressed
		LocalSaveData.overwrite_exisitng_filename(gltf_file_path, file_name)
		_duplicate_model_popup.visible = false
		_duplicate_model_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	refresh_artifacts()
	

func open_artifact(data : ArtifactData):
	var gltf_file_path = data.localDir
	#Check the file can be opened
	if (not gltf_file_path.ends_with(".gltf") and not gltf_file_path.ends_with(".glb")) or ( not LocalSaveData._is_file_valid(gltf_file_path)):
		_invalid_file_popup.visible = true
		_invalid_file_popup.mouse_filter = Control.MOUSE_FILTER_STOP
		LocalSaveData._remove_entry(gltf_file_path) #- bug found where it deletes all the data
		return
	
	if is_instance_valid(loaded_artifact):
		loaded_artifact.queue_free()
	
	data.gltfUri = gltf_file_path
	
	var model = LocalGltfModel.create(data)
	add_child(model)
	#_on_model_begin_load()
	model.preview_load_completed.connect(_on_model_preview_load_complete)
	model.load_completed.connect(_on_model_load_complete)
	model.load_progress.connect(_on_model_load_progress)
	
	loaded_artifact = model # set here to prevent null pointer dereference
	model.load_artifact()
	emit_signal("artifact_loaded")
	
	#
#func refresh_artifacts() -> Array[ArtifactData]:
	#if(Preferences.read_pref("offline mode")):
		#artifacts = CacheManager.get_artifact_data()
	#else:
		#artifacts = await _fetcher.fetch_artifacts()
		#artifacts_refreshed.emit(artifacts)
		#
		#if artifacts.size() == 0:
			#artifacts = CacheManager.get_artifact_data()
	#return artifacts


func _on_server_controller_artifact_loaded() -> void:
		if is_instance_valid(loaded_artifact):
			if not loaded_artifact.load_finished:
				loaded_artifact.stop_loading()
			loaded_artifact.queue_free()
