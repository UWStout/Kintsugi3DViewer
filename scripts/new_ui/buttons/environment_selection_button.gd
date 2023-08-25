# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name EnvironmentSelectionButton extends ExclusiveToggleButton

@onready var environment_label = $HBoxContainer/environment_label
@onready var environment_preview = $HBoxContainer/MarginContainer/CenterContainer/environment_preview

var index : int
var environment_name : String
var controller : EnvironmentController

func set_data(new_index : int, new_name : String, new_controller : EnvironmentController):
	index = new_index
	controller = new_controller
	environment_name = new_name
	environment_label.text = new_name

func _on_toggle_on():
	if not controller == null:
		controller.open_scene(index)
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()

func _display_toggled_on():
	environment_label.self_modulate = Color8(36, 36, 36, 255)
	environment_preview.self_modulate = Color8(36, 36, 36, 255)
	super._display_toggled_on()

func _display_toggled_off():
	environment_label.self_modulate = Color8(217, 217, 217, 255)
	environment_preview.self_modulate = Color8(217, 217, 217, 255)
	super._display_toggled_off()
