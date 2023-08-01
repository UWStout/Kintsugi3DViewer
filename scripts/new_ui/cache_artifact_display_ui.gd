extends MarginContainer

@onready var name_label = $Panel/HBoxContainer/CenterContainer/HBoxContainer/name_label
@onready var size_label = $Panel/HBoxContainer/CenterContainer/HBoxContainer/size_label

@onready var delete_button = $Panel/HBoxContainer/CenterContainer2/delete_button
@onready var favorite_button = $Panel/HBoxContainer/CenterContainer3/favorite_button

var artifact_name : String
var artifact_url_name : String

var confirmation_panel : ConfirmationPanel

func initialize_from_artifact(data : ArtifactData):
	artifact_name = data.name
	artifact_url_name = data.gltfUri.get_base_dir()
	
	name_label.text = artifact_name
	size_label.text = "(" + str(CacheManager.get_size_in_mb(artifact_url_name)) + " mb)"
	
	if CacheManager.is_persistent(artifact_url_name):
		favorite_button.toggle_on()
	
	CacheManager.cache_item_deleted.connect(check_if_valid)

func _on_delete_button_pressed():
	confirmation_panel.prompt_confirmation("DELETE OBJECT", "You will not be able to recover it", canceled, delete_artifact) 
	#self.queue_free()

func check_if_valid():
	if not CacheManager.is_in_cache(artifact_url_name):
		self.queue_free()
	pass

func delete_artifact():
	CacheManager.remove_from_cache(artifact_url_name)

func canceled():
	pass
