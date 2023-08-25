# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

@tool
class_name DropdownButton extends Panel

enum side_enum {LEFT, RIGHT}

@export_category("Options")
@export var options : Array[String]
@export var option_descriptions : Array[String]
@export var selected_option : int = 0 : set = _set_selected_option

@export_category("Config")
@export var button_width : int = 200
@export var option_side : side_enum = side_enum.LEFT
@export var option_width : int = 400
@export var option_height : int = 50

@onready var selected_option_label = $VBoxContainer/HBoxContainer/HBoxContainer2/MarginContainer/selected_option_label
@onready var expanding_panel = $VFlowContainer/expanding_panel
@onready var v_flow_container = $VFlowContainer
@onready var v_box_container = $VFlowContainer/expanding_panel/VBoxContainer
@onready var button_group = $VFlowContainer/button_group
@onready var icon = $VBoxContainer/HBoxContainer/HBoxContainer3/MarginContainer/CenterContainer/icon

var expanded_icon = preload("res://assets/UI 2D/Icons/Expanded Light Customization/Light Expand/V1/LightExpand_In_White_V1.svg")
var shrunk_icon = preload("res://assets/UI 2D/Icons/Expanded Light Customization/Light Expand/V1/LightExpand_Out_White_V1.svg")

var dropdown_selection_button : PackedScene = preload("res://scenes/new_ui/dropdown_selection_button.tscn")

func _ready():
	custom_minimum_size.x = button_width
	expanding_panel.custom_minimum_size.x = option_width
	v_box_container.custom_minimum_size.x = option_width
	size.x = button_width
	expanding_panel.size.x = option_width
	
	if option_side == side_enum.LEFT:
		v_flow_container.position.x = -(expanding_panel.size.x - size.x)
	
	option_descriptions.resize(options.size())
	
	expanding_panel.maximized_size = options.size() * option_height
	for i in range(0, options.size()):
		var button = dropdown_selection_button.instantiate() as DropdownSelectionButton
		v_box_container.add_child(button)
		
		button.initialize_button(options[i], option_descriptions[i], i, button_group, self)
		button.custom_minimum_size.y = option_height
	
	for button in v_box_container.get_children():
		if button.index == selected_option:
			button._pressed()


func _set_selected_option(option : int):
	selected_option = clamp(option, 0, options.size() - 1)

func _on_button_pressed():
	#print("BUTTON PRESSED!")
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _is_position_in_button(event.position):
			if _is_position_in_control(event.position, self) and not _is_position_in_control(event.position, expanding_panel) and expanding_panel.is_expanded:
				expanding_panel.shrink()
				icon.texture = shrunk_icon
			expanding_panel.expand()
			icon.texture = expanded_icon
		else:
			expanding_panel.shrink()
			icon.texture = shrunk_icon

func _is_position_in_button(position : Vector2i):
	return _is_position_in_control(position, self) or _is_position_in_control(position, expanding_panel)
	pass

func _is_position_in_control(position : Vector2i, control : Control) -> bool:
	var control_rect = control.get_global_rect()
	return (position.x >= control_rect.position.x 
	and position.x <= control_rect.position.x + control_rect.size.x
	and position.y >= control_rect.position.y
	and position.y <= control_rect.position.y + control_rect.size.y)

func select_option(index : int):
	if index < 0 or index >= options.size():
		print("INVALID INDEX: " + str(index))
		return
	
	selected_option_label.text = options[index]
	expanding_panel.shrink()
	icon.texture = shrunk_icon
	selected_option = index
	
	on_option_selected(index)

func on_option_selected(selected_index : int):
	pass
