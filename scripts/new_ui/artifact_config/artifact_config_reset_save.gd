# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Kyle Boatwright, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
class_name ResetSaveConfig extends Node

@export var config: ArtifactConfigButton
@export var local_controller: LocalArtifactsController
var current_artifact
signal reset_button_pressed

func _ready() -> void:
	local_controller.artifact_changed.connect(_on_artifact_changed)

func _on_save_button_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	LocalSaveData.overwrite_camera_constraints(current_artifact.localDir, config.min_zoom, config.max_zoom)
	current_artifact.max_distance = config.max_zoom
	current_artifact.min_distance = config.min_zoom
	#TODO: re-assign artifact in artifacts_controller with updated artifact data
	local_controller.refresh_artifacts()
	
	#edge case: if you save new constraints and then reset without exiting the configurations menu,
		#it will visually reset to previous save instead of the current save
	#LocalArtifactsController


func _on_reset_button_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	reset_button_pressed.emit(current_artifact.min_distance, current_artifact.max_distance)


func _on_artifact_changed(artifact):
	current_artifact = artifact
	reset_button_pressed.emit(current_artifact.min_distance, current_artifact.max_distance)
