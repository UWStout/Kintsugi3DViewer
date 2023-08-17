# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name DropdownSelectionButton extends ExclusiveToggleButton

@onready var title_label = $HBoxContainer/MarginContainer/title_label
@onready var description_label = $HBoxContainer/description_label

var connected_button : DropdownButton
var index : int = -1

func initialize_button(title : String, description : String, option_index : int, button_group : ExclusiveToggleGroup, dropdown_button : DropdownButton):
	title_label.text = title
	if not description.is_empty():
		description_label.text = "- " + description
	button_group.register_button(self)
	connected_button = dropdown_button
	index = option_index
	
	if index == connected_button.selected_index:
		_pressed()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_global_rect().has_point(event.position):
			_pressed()

func _on_toggle_on():
	connected_button.select_option(index)
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()
