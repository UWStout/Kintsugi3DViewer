# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactConfigUI extends ContextMenu

@export var artifact_config_menu : ArtifactConfigButton
@export var rotate_artifact_button : RotateArtifactButton

@onready var v_box_container = $ScrollContainer/VBoxContainer
@onready var button_group = $button_group

signal camera_setting_changed(minDistance: float, maxDistance: float)

func _ready() -> void:
	artifact_config_menu.camera_setting_changed.connect(_on_camera_setting_changed)

func _on_camera_setting_changed(minimum: float, maximum: float) -> void:
	camera_setting_changed.emit(minimum, maximum)
#func initialize_list(environments : Array[DisplayEnvironment]):
	#for i in range(0, environments.size()):
		#create_button(i, environments[i].environment_name)
	#
	#if v_box_container.get_child_count() >= 1:
		#v_box_container.get_child(0)._pressed()
##
#func create_button(index : int, button_name : String):
	#var button = artifact_config_menu.instantiate() as ArtifactConfigButton
	#v_box_container.add_child(button)
#
#func hide_non_matching(name : String):
	#for child in v_box_container.get_children():
		#var button = child as EnvironmentSelectionButton
		#if button.environment_name.to_lower().begins_with(name.to_lower()):
			#button.visible = true
		#else:
			#button.visible = false
#
#func show_all():
	#for child in v_box_container.get_children():
		#var button = child
		#button.visible = true
