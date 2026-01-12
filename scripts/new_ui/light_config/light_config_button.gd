# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LightConfigButton extends MarginContainer

var light_strength : float
var light_angle : int
var light_color : Color

@export var light_strength_label : Label
@export var light_angle_label : Label
@export var miniature_color_display : Control
@export var label : Label
@export var button : Button
@export var texture_rect : TextureRect

@export var color_picker : ColorPicker
@export var text_edit : LineEdit
@export var strength_scroll_bar : ScrollBar
@export var angle_scroll_bar : ScrollBar
@export var value_scroll_bar : ScrollBar

@export var expand_icon : CompressedTexture2D
@export var shrunk_icon : CompressedTexture2D

var connected_light : NewLightWidget

func set_button_name(new_name : String):
	label.text = new_name

func update_light_strength(new_strength : float):
	light_strength = new_strength
	
	var text = str(light_strength)
	if not text.length() == 1:
		text = text.substr(1)
	
	light_strength_label.text = text
	
	if not connected_light == null:
		connected_light.set_color_strength(light_strength)

func update_light_angle(new_angle : float):
	light_angle = new_angle
	
	light_angle_label.text = str(light_angle) + "°"
	
	if not connected_light == null:
		connected_light.set_light_angle(light_angle)

func update_light_color(new_color : Color):
	light_color = new_color
	
	var adjusted_light_color = Color(new_color.r, new_color.g, new_color.b, 1)
	adjusted_light_color.v = max(adjusted_light_color.v, 0.5)
	
	miniature_color_display.self_modulate = adjusted_light_color
	
	if not connected_light == null:
		connected_light._set_color_UTIL(light_color)

func set_color_from_light(light : NewLightWidget):
	light_color = light.color
	light_strength = light.get_color_strength()
	light_angle = light.get_light_angle()
	color_picker.color = light_color
	miniature_color_display.self_modulate = light_color
	text_edit.text = "#" + light_color.to_html()
	
	strength_scroll_bar.value = light_strength * 1000.0
	angle_scroll_bar.value = light_angle
	value_scroll_bar.value = (-light_color.v + 1) * 100.0
	
	set_connected_light(light)

func set_toggle_group(group : ExclusiveToggleGroup):
	group.register_button(button)

func set_connected_light(light : NewLightWidget):
	connected_light = light

func on_button_open():
	#print("light made material")
	connected_light.make_material()
	texture_rect.texture = expand_icon
	#connected_light.controller.select_light(null)
	pass

func on_button_close():
	#print("light made immaterial")
	connected_light.make_immaterial()
	connected_light.controller.force_hide_lights()
	texture_rect.texture = shrunk_icon
	pass

func delete_light():
	connected_light.controller.select_light(null)
	connected_light.queue_free()
	queue_free()
