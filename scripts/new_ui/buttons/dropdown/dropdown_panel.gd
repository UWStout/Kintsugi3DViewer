# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name DropdownPanel extends Panel

@export var exclusive_toggle_group : ExclusiveToggleGroup
@export var expanding_panel : ExpandingPanel
@export var v_box_container : BoxContainer

@export var dropdown_selection_button_scene : PackedScene

var linked_dropdown_button : DropdownButton

func set_width(width : int):
	size.x = width
	expanding_panel.size.x = width

func create_buttons(options : Array[String], descriptions : Array[String], button_height : int):
	size.y = options.size() * button_height
	expanding_panel.maximized_size = options.size() * button_height
	
	for i in range(0, options.size()):
		var button = dropdown_selection_button_scene.instantiate() as DropdownSelectionButton
		v_box_container.add_child(button)
		
		button.initialize_button(options[i], descriptions[i], i, exclusive_toggle_group, linked_dropdown_button)
		button.custom_minimum_size.y = button_height
		button.size.y = button_height

func open_panel():
	await expanding_panel.expand()

func close_panel():
	await expanding_panel.shrink()
	queue_free()
