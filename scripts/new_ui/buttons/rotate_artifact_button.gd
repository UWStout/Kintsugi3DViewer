# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name RotateArtifactButton extends ToggleButton

@export var artifacts_manager: ArtifactsManager
@export var artifacts_controller : ArtifactsController
@export var scene_camera : CameraRig
@export var sidebar_context_menu : ExpandingContextPanel
@export var light_selection_ui : LightSelectionUI

@export var _lerp_speed : float = 0.5

var is_grabbed : bool = false

func _ready() -> void:
	artifacts_manager.active_controller_changed.connect(_on_active_controller_changed)

func _pressed():
	if artifacts_controller.loaded_artifact == null or not artifacts_controller.loaded_artifact.load_finished:
		return
	
	light_selection_ui.button_group.close_all_buttons()
	
	#if sidebar_context_menu.is_context_expanded("lights_selection"):
		#sidebar_context_menu.shrink()
	
	super._pressed()

func _on_toggle_on():
	scene_camera.rig_enabled = false
	super._on_toggle_on()

func _on_toggle_off():
	scene_camera.rig_enabled = true
	super._on_toggle_off()

func _input(event):
	if not _is_toggled or artifacts_controller.loaded_artifact == null or not artifacts_controller.loaded_artifact.load_finished:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_grabbed = true
		else:
			is_grabbed = false
	
	if event is InputEventMouseMotion and is_grabbed:
		var yaw_val = event.relative.x * 0.01
		var pitch_val = event.relative.y * 0.01
		
		var artifact = artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.rotated(Vector3.UP, yaw_val).orthonormalized()
		artifact.transform.basis = artifact.transform.basis.rotated(scene_camera.camera.global_transform.basis.x, pitch_val).orthonormalized()

func _process(delta):
	#print(_is_toggled)
	if not _is_toggled:
		lerp_to_default_orientation(delta * _lerp_speed)

func lerp_to_default_orientation(delta : float):
	if not artifacts_controller.loaded_artifact == null and not artifacts_controller.loaded_artifact.transform.basis.is_equal_approx(Basis.IDENTITY):
		var artifact = artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.slerp(Basis.IDENTITY, delta).orthonormalized()
		

func _on_active_controller_changed(new_controller: ArtifactsController):
	artifacts_controller = new_controller
