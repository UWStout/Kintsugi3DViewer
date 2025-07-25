class_name LocalArtifactsController extends ArtifactsController

@export var _save_import_panel : CenterContainer
@export var _save_import_button: Button
@export var _duplicate_model_popup : CenterContainer
@export var _overwrite_duplicate_button : Button

@export var _invalid_file_popup : CenterContainer


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
	
	await refresh_artifacts()
	
	var args = OS.get_cmdline_args()
	_open_artifact_through_file(args[0])

	#$"../new_ui_root/CenterContainer/Label".text += "\n" + arg
	
	#_open_artifact_through_file("C:\\Users\\BetanskiTyler\\test_directory\\guan-yu\\model.glb")
	
	
func refresh_artifacts() -> Array[ArtifactData]:
	artifacts = LocalSaveData.get_artifact_data()
	return artifacts

func _open_artifact_through_file(gltf_file_path : String):
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
	#after model loads, show prompt to name filepath
	_save_import_panel.visible = true
	_save_import_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var file_name = await _save_import_button.file_name_chosen
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
	

func _open_saved_artifact_through_file(gltf_file_path : String):
	#Check the file can be opened
	if (not gltf_file_path.ends_with(".gltf") and not gltf_file_path.ends_with(".glb")) or ( not LocalSaveData._is_file_valid(gltf_file_path)):
		_invalid_file_popup.visible = true
		_invalid_file_popup.mouse_filter = Control.MOUSE_FILTER_STOP
		LocalSaveData._remove_entry(gltf_file_path) #- bug found where it deletes all the data
	
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
	
	#
#func refresh_artifacts() -> Array[ArtifactData]:
	#if(Preferences.read_pref("offline mode") == 0):
		#pass
	#if(Preferences.read_pref("offline mode") == 1):
		#artifacts = CacheManager.get_artifact_data()
	#else:
		#artifacts = await _fetcher.fetch_artifacts()
		#artifacts_refreshed.emit(artifacts)
		#
		#if artifacts.size() == 0:
			#artifacts = CacheManager.get_artifact_data()
	#return artifacts
