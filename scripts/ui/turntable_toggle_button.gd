# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name TurntableButton extends Button

var _is_toggled : bool = false

var _is_grabbed = false

@export var _return_to_default_orientation : bool = true
@export var _lerp_speed : float = 0.5
@export var _scene_camera_rig : CameraRig
@export var _artifacts_controller : ArtifactsController
@export var _artifacts_manager : ArtifactsManager
@export var _customize_lighting_button : CustomizeLightingButton

func _ready() -> void:
	#await _artifacts_controller._ready()
	#_artifacts_controller = _artifacts_controller.get_current_controller()
	_artifacts_manager.active_controller_changed.connect(_on_active_controller_changed)
	_on_active_controller_changed(_artifacts_manager.active_controller)

func _pressed():
	_customize_lighting_button.override_stop_customizing()
	
	if _is_toggled:
		_is_toggled = false
		text = "Rotate Object: OFF"
		_scene_camera_rig.rig_enabled = true
	else:
		_is_toggled = true
		text = "Rotate Object: ON"
		_scene_camera_rig.rig_enabled = false


func _input(event):
	if not _is_toggled or _artifacts_controller.loaded_artifact == null or not _artifacts_controller.loaded_artifact.load_finished:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_grabbed = true
		else:
			_is_grabbed = false
	
	if event is InputEventMouseMotion and _is_grabbed:
		
		var yaw_val = event.relative.x * 0.01
		var pitch_val = event.relative.y * 0.01
		
		var artifact = _artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.rotated(Vector3.UP, yaw_val).orthonormalized()
		artifact.transform.basis = artifact.transform.basis.rotated(_scene_camera_rig.camera.global_transform.basis.x, pitch_val).orthonormalized()

func _process(delta):
	#if not _is_toggled:
		#return_to_default_orientation()
		#lerp_to_default_orientation(delta * _lerp_speed)
	pass

func return_to_default_orientation():
	if not _artifacts_controller.loaded_artifact == null:
		_artifacts_controller.loaded_artifact.transform.basis = Basis.IDENTITY
	pass

func lerp_to_default_orientation(delta : float):
	if not _artifacts_controller.loaded_artifact == null and not _artifacts_controller.loaded_artifact.transform.basis.is_equal_approx(Basis.IDENTITY):
		var artifact = _artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.slerp(Basis.IDENTITY, delta).orthonormalized()

func force_quit():
	_is_toggled = false
	_is_grabbed = false
	text = "Turntable: OFF"
	_scene_camera_rig.rig_enabled = true
	

func _on_active_controller_changed(new_controller: ArtifactsController):
	_artifacts_controller = new_controller
