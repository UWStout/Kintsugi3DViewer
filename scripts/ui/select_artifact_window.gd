# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Window
@export var artifacts_manager : ArtifactsManager
@export var artifacts_controller : ArtifactsController
@export var artifacts_controller_node_path : NodePath
@export var select_artifact_button : PackedScene
@export var v_box_container : BoxContainer

func _ready() -> void:
	#await artifacts_controller._ready()
	#artifacts_controller = artifacts_controller.get_current_controller()
	artifacts_manager.active_controller_changed.connect(_on_active_controller_changed)
	_on_active_controller_changed(artifacts_manager.active_controller)
	
func on_open():
	populate_list()


func _on_close_requested():
	hide()
	pass


func populate_list():
	# Refresh artifacts to make sure ui is up to date
	await artifacts_controller.refresh_artifacts()
	
	# Remove all buttons
	for child in v_box_container.get_children():
		child.queue_free()
		pass
	
	for artifact in artifacts_controller.artifacts:
		var new_button = select_artifact_button.instantiate()
		
		new_button.artifacts_controller = artifacts_controller
		new_button.target_artifact = artifact
		new_button.parent_window = self
		new_button.visible = true
		
		v_box_container.add_child(new_button)
		pass
	pass

func _on_active_controller_changed(new_controller: ArtifactsController):
	artifacts_controller = new_controller
