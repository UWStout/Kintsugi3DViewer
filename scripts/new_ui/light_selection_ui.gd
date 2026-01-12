# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LightSelectionUI extends ContextMenu

@export var light_config_button : PackedScene
@export var rotate_artifact_button : RotateArtifactButton

@export var v_box_container : BoxContainer
@export var new_light_button : Button
@export var button_group : ExclusiveToggleGroup

func on_context_expanded():
	rotate_artifact_button.toggle_off()
	super.on_context_expanded()

func on_context_shrunk():
	button_group.close_all_buttons()

	super.on_context_shrunk()

func create_button_for_light(light : LightWidget):
	var new_button = light_config_button.instantiate()
	
	var num_children = v_box_container.get_children().size()
	v_box_container.add_child(new_button)
	new_button.set_button_name("Light")
	new_button.set_toggle_group(button_group)
	
	new_button.set_color_from_light(light)

func clear_buttons():
	for i in range(1, v_box_container.get_children().size()):
		v_box_container.get_child(i).queue_free()
