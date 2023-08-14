class_name ArtifactSelectionButton extends ExclusiveToggleButton

@onready var artifact_label = $HBoxContainer/artifact_label
@onready var artifact_preview = $HBoxContainer/MarginContainer/CenterContainer/artifact_preview
@onready var artifact_status = $HBoxContainer/HBoxContainer/MarginContainer2/CenterContainer/artifact_status

var not_downloaded_icon = preload("res://assets/ui/light_none.png")
var downloaded_icon = preload("res://assets/ui/UI_V2/CacheFavorites_V2/Unfavorited_Light_V2.svg")
var favorited_icon = preload("res://assets/ui/UI_V2/CacheFavorites_V2/Favorited_Light_V2.svg")



var data : ArtifactData
var controller : ArtifactsController

func set_data(new_data : ArtifactData, new_controller : ArtifactsController):
	data = new_data
	controller = new_controller
	artifact_label.text = data.name

func _pressed():
	if not controller == null and not controller.loaded_artifact == null:
		if not controller.loaded_artifact.load_finished:
			return
	
	super._pressed()

func _on_toggle_on():
	if not controller == null:
		controller.display_artifact_data(data)
		
		for button in toggle_group.connected_buttons:
			if not button == self:
				button.make_inactive()
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()

func _display_toggled_on():
	artifact_label.self_modulate = Color8(36, 36, 36, 255)
	artifact_preview.self_modulate = Color8(36, 36, 36, 255)
	artifact_status.self_modulate = Color8(36, 36, 36, 255)
	super._display_toggled_on()

func _display_toggled_off():
	artifact_label.self_modulate = Color8(217, 217, 217, 255)
	artifact_preview.self_modulate = Color8(217, 217, 217, 255)
	artifact_status.self_modulate = Color8(217, 217, 217, 255)
	super._display_toggled_off()

func make_inactive():
	if controller.loaded_artifact.load_finished:
		return
	
	artifact_label.self_modulate = Color8(167, 167, 167, 255)
	artifact_preview.self_modulate = Color8(167, 167, 167, 255)

func _on_favorite_artifact_button_pressed():
	if not CacheManager.is_in_cache(data.gltfUri.get_base_dir()):
		return
	
	if CacheManager.is_persistent(data.gltfUri.get_base_dir()):
		CacheManager.make_not_persistent(data.gltfUri.get_base_dir())
	else:
		CacheManager.make_persistent(data.gltfUri.get_base_dir())

func _process(delta):
	if CacheManager.is_in_cache(data.gltfUri.get_base_dir()):
		artifact_status.texture = downloaded_icon
		
		if CacheManager.is_persistent(data.gltfUri.get_base_dir()):
			artifact_status.texture = favorited_icon
	else:
		artifact_status.texture = not_downloaded_icon
	pass
