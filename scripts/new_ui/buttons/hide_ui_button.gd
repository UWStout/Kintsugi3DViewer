# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name HideUIButton extends ToggleButton

@onready var texture_rect = $CenterContainer/TextureRect

var shown_icon = preload("res://assets/UI 2D/Icons/Top Dock/UI Visability/V2/UIVisability_Shown_White_V2.svg")
var hidden_icon = preload("res://assets/UI 2D/Icons/Top Dock/UI Visability/V2/UIVisability_Hidden_White_V2.svg")

@export var nodes_to_hide : Array[NodePath]
@export var lights_selection : LightSelectionUI
@export var speed : float = 0.1

var animating = false

func _on_toggle_on():
	if animating:
		_is_toggled = false
		return

	lights_selection.on_context_shrunk()
	hide_nodes()
	super._on_toggle_on()

func _on_toggle_off():
	if animating:
		_is_toggled = true
		return
	
	show_nodes()
	super._on_toggle_off()

func _display_toggled_on():
	texture_rect.texture = hidden_icon
	super._display_toggled_on()

func _display_toggled_off():
	texture_rect.texture = shown_icon
	super._display_toggled_off()


func hide_nodes():
	animating = true
	
	var progress = 0
	while progress < 1:
		progress += speed
		await get_tree().create_timer(0.01).timeout
		
		for node_path in nodes_to_hide:
			var node = get_node(node_path) as Control
			node.modulate = Color(1,1,1, 1 - progress)
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.modulate = Color(1,1,1,0)
		node.visible = false
	
	animating = false

func show_nodes():
	animating = true
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.visible = true
	
	var progress = 0
	while progress < 1:
		progress += speed
		await get_tree().create_timer(0.01).timeout
		
		for node_path in nodes_to_hide:
			var node = get_node(node_path) as Control
			node.modulate = Color(1,1,1, progress)
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.modulate = Color(1,1,1,1)
	
	animating = false
