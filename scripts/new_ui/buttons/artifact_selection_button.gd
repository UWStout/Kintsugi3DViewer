class_name ArtifactSelectionButton extends ExclusiveToggleButton

@onready var artifact_label = $HBoxContainer/artifact_label
@onready var artifact_preview = $HBoxContainer/MarginContainer/CenterContainer/artifact_preview

var data : ArtifactData
var controller : ArtifactsController

func set_data(new_data : ArtifactData, new_controller : ArtifactsController):
	data = new_data
	controller = new_controller
	artifact_label.text = data.name

func _on_toggle_on():
	if not controller == null:
		controller.display_artifact_data(data)
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()

func _display_toggled_on():
	artifact_label.self_modulate = Color8(36, 36, 36, 255)
	artifact_preview.self_modulate = Color8(36, 36, 36, 255)
	super._display_toggled_on()

func _display_toggled_off():
	artifact_label.self_modulate = Color8(217, 217, 217, 255)
	artifact_preview.self_modulate = Color8(217, 217, 217, 255)
	super._display_toggled_off()
