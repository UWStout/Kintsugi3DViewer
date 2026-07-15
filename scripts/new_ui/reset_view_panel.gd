class_name ResetViewPanel extends Node

@export var scene_camera : CameraRig
@export var panel : Panel

func reset_panning() -> void:
	scene_camera.set_rig_transform(scene_camera.artifactsManager.active_controller.loaded_artifact.transform)
	scene_camera.apply_yaw(-PI/2)

func reset_zoom() -> void:
	scene_camera.set_zoom(scene_camera.dolly_initial_distance) 
	
	

func _on_zoom_button_button_up() -> void:
	reset_zoom()
	panel.visible = false

func _on_panning_button_button_up() -> void:
	reset_panning()
	panel.visible = false


func _on_both_button_button_up() -> void:
	reset_panning()
	reset_zoom()
	panel.visible = false
