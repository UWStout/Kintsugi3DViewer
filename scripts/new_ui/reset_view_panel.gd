class_name ResetViewPanel extends Node

@export var scene_camera : CameraRig
@export var panel : Panel
@export var option_drop_down : OptionButton
@export var description : Label

func show(message) -> void:
	panel.visible = true
	description.text = message + "  Would you like to reset?"
	
func hide() -> void:
	panel.visible = false

func reset_panning() -> void:
	scene_camera.reset_rig_position()
	#scene_camera.apply_yaw(-PI/2)

func reset_zoom() -> void:
	scene_camera.reset_zoom()

func _on_zoom_button_button_up() -> void:
	reset_panning()
	reset_zoom()
	panel.visible = false

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			pass
		1:
			reset_zoom()
			panel.visible = false
			option_drop_down.select(0)
		2:
			reset_panning()
			panel.visible = false
			option_drop_down.select(0)
