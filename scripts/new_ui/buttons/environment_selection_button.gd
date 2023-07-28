class_name EnvironmentSelectionButton extends ExclusiveToggleButton

@onready var environment_label = $HBoxContainer/environment_label
@onready var environment_preview = $HBoxContainer/MarginContainer/CenterContainer/environment_preview

var index : int
var environment_name : String
var controller : EnvironmentController

func set_data(new_index : int, new_name : String, new_controller : EnvironmentController):
	index = new_index
	controller = new_controller
	environment_name = new_name
	environment_label.text = new_name

func _on_toggle_on():
	if not controller == null:
		controller.open_scene(index)
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()

func _display_toggled_on():
	environment_label.self_modulate = Color8(36, 36, 36, 255)
	environment_preview.self_modulate = Color8(36, 36, 36, 255)
	super._display_toggled_on()

func _display_toggled_off():
	environment_label.self_modulate = Color8(217, 217, 217, 255)
	environment_preview.self_modulate = Color8(217, 217, 217, 255)
	super._display_toggled_off()
