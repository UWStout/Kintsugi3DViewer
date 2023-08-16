# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name EnvironmentSelectionUI extends ContextMenu

@export var environment_selection_button : PackedScene
@export var environment_controller : EnvironmentController

@onready var button_group = $button_group
@onready var v_box_container = $ScrollContainer/VBoxContainer
@onready var searchbar = $header/VBoxContainer2/MarginContainer2/CenterContainer/searchbar

func initialize_list(environments : Array[DisplayEnvironment]):
	for i in range(0, environments.size()):
		create_button(i, environments[i].environment_name)
	
	if v_box_container.get_child_count() >= 1:
		v_box_container.get_child(0)._pressed()

func create_button(index : int, button_name : String):
	var button = environment_selection_button.instantiate() as EnvironmentSelectionButton
	v_box_container.add_child(button)
	
	button.set_data(index, button_name, environment_controller)
	
	button_group.register_button(button)

func hide_non_matching(name : String):
	for child in v_box_container.get_children():
		var button = child as EnvironmentSelectionButton
		if button.environment_name.to_lower().begins_with(name.to_lower()):
			button.visible = true
		else:
			button.visible = false

func show_all():
	for child in v_box_container.get_children():
		var button = child
		button.visible = true

func _on_searchbar_text_changed():
	var text = searchbar.text
	
	if text.is_empty():
		show_all()
	else:
		hide_non_matching(text)
