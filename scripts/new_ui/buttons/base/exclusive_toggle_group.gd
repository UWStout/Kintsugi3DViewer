# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExclusiveToggleGroup extends Node

@export var can_toggle_off_all : bool = true

var connected_buttons : Array[ExclusiveToggleButton]
var active_button : ExclusiveToggleButton = null

func register_button(new_button : ExclusiveToggleButton):
	if not connected_buttons.has(new_button):
		connected_buttons.push_back(new_button)
		new_button.toggle_group = self

func make_button_active(button : ExclusiveToggleButton):
	if not connected_buttons.has(button):
		return
	
	if active_button == null:
		active_button = button
		await active_button.toggle_on()
		return
	
	await active_button.toggle_off()

	active_button = button
	await active_button.toggle_on()

func make_button_inactive(button : ExclusiveToggleButton):
	if not connected_buttons.has(button) or not active_button == button:
		return
	
	if can_toggle_off_all:
		active_button = null
		button.toggle_off()

func close_all_buttons():
	if not active_button == null and can_toggle_off_all:
		await active_button.toggle_off()
		active_button = null
