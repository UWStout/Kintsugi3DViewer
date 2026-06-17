# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ObjectDisplayConfigButton extends MarginContainer

@export var button : Button
@export var texture_rect : TextureRect

@export var pedistal_check_box : CheckBox
@export var floating_check_box : CheckBox
@export var check_box_list : Array[CheckBox] = []
@export var expand_icon : CompressedTexture2D
@export var shrunk_icon : CompressedTexture2D

@export var save_reset: ResetSaveConfig

var display_option : int 
signal display_setting_changed(dis_option: int)

func _ready() -> void:
	check_box_list = [pedistal_check_box, floating_check_box]
	display_option = 0
	save_reset.display_rbp.connect(_on_reset_button_pressed)


func _on_pedestal_check_box_button_up() -> void:
	if display_option != 0:
		check_box_list[display_option].set_pressed(false)
		display_option = 0
		display_setting_changed.emit(display_option)
	
	else: 
		pedistal_check_box.set_pressed(true)
	#print(display_option)

func _on_floating_check_box_button_up() -> void:
	if display_option != 1:
		check_box_list[display_option].set_pressed(false)
		display_option = 1
	else: 
		pedistal_check_box.set_pressed(true)
		display_option = 0
	# print(display_option)	
	display_setting_changed.emit(display_option)

func _on_reset_button_pressed(dis_opt):
	for cb in check_box_list:
		cb.set_pressed(false)
	
	display_option = dis_opt
	check_box_list[display_option].set_pressed(true)
	display_setting_changed.emit(display_option)
