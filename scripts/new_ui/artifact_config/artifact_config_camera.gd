# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactConfigButton extends MarginContainer



@export var button : Button
@export var texture_rect : TextureRect

@export var min_scroll_bar : ScrollBar
@export var max_scroll_bar : ScrollBar
@export var pan_scroll_bar : ScrollBar
@export var rot_scroll_bar : ScrollBar

@export var min_label : Label
@export var max_label : Label
@export var pan_label : Label
@export var rot_label : Label


@export var expand_icon : CompressedTexture2D
@export var shrunk_icon : CompressedTexture2D

var min_zoom = 0.0
var max_zoom = 50.0
signal camera_setting_changed(min: float, max: float)


func on_button_open():
	#print("light made material")
	#connected_light.make_material()
	texture_rect.texture = expand_icon
	#connected_light.controller.select_light(null)
	pass

func on_button_close():
	#print("light made immaterial")
	#connected_light.make_immaterial()
	#connected_light.controller.force_hide_lights()
	texture_rect.texture = shrunk_icon
	pass


func _on_rot_scroll_bar_value_changed(value: float) -> void:
	rot_label.text = str(value) + "°"


func _on_pan_scroll_bar_value_changed(value: float) -> void:
	pan_label.text = str(value) + ""


func _on_max_scroll_bar_value_changed(value: float) -> void:
	if value > min_zoom:
		max_zoom = value
	else:
		max_zoom = min_zoom
		max_scroll_bar.value = max_zoom
		
	max_label.text = str(max_zoom) + ""
	camera_setting_changed.emit(min_zoom, max_zoom)

func _on_min_scroll_bar_value_changed(value: float) -> void:
	if value < max_zoom:
		min_zoom = value
	else:
		min_zoom = max_zoom
		min_scroll_bar.value = min_zoom
		
	min_label.text = str(min_zoom) + ""
	camera_setting_changed.emit(min_zoom, max_zoom)
	
	min_label.text = str(min_zoom) + ""
	camera_setting_changed.emit(min_zoom, max_zoom)
