# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name DropdownButton extends ToggleButton

enum side_enum {LEFT, RIGHT}

@export var options : Array[String]
@export var descriptions : Array[String]

@export var panel_side : side_enum = side_enum.LEFT
@export var panel_width : int = 200
@export var option_height : int = 50

@export var panel_root : Control

@export var selected_index : int = 0

@export var texture_rect : TextureRect
@export var label : Label

@export var dropdown_panel_scene: PackedScene = preload("res://scenes/new_ui/dropdown_panel.tscn")
var expanding_icon = preload("res://assets/UI 2D/Icons/Expanded Light Customization/Light Expand/V1/LightExpand_Out_White_V1.svg")
var shrinking_icon = preload("res://assets/UI 2D/Icons/Expanded Light Customization/Light Expand/V1/LightExpand_In_White_V1.svg")

var panel : DropdownPanel = null

func _ready():
	selected_index = clamp(selected_index, 0, options.size())
	select_option(selected_index)
	descriptions.resize(options.size())

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(event.position):
			toggle_off()

func _on_toggle_on():
	print("Loaded resource:", dropdown_panel_scene)
	print("Is PackedScene:", dropdown_panel_scene is PackedScene)

	var instance = dropdown_panel_scene.instantiate()
	print("Instantiated node:", instance)
	if (instance != null):
		print("Instance type:", instance.get_class())
	else:
		push_error("⚠️ Instantiate() failed! Scene likely has a broken reference.")
		return
	panel = dropdown_panel_scene.instantiate() as DropdownPanel
	panel_root.add_child(panel)
		
	panel.linked_dropdown_button = self
	panel.set_width(panel_width)
	
	var rect = get_global_rect()
	panel.global_position.y = rect.position.y + rect.size.y
	
	if panel_side == side_enum.LEFT:
		panel.global_position.x = rect.position.x - (panel_width - size.x)
	else:
		panel.global_position.x = rect.position.x
	
	panel.create_buttons(options, descriptions, option_height)
	panel.open_panel()
	
	texture_rect.texture = shrinking_icon
	
	super._on_toggle_on()

func _on_toggle_off():
	if not panel == null:
		panel.close_panel()
	
	texture_rect.texture = expanding_icon
	
	super._on_toggle_off()

func select_option(index : int):
	if index < 0 or index >= options.size():
		return

	label.text = options[index]
	selected_index = index
	
	on_select_option(index)

func on_select_option(index : int):
	pass
