# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ConfirmationPanel extends CenterContainer

@onready var header = $confirmation_panel/VBoxContainer/MarginContainer/CenterContainer/header
@onready var description = $confirmation_panel/VBoxContainer/MarginContainer2/CenterContainer/description

@onready var cancel_button = $confirmation_panel/VBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/cancel_button
@onready var confirm_button = $confirmation_panel/VBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/confirm_button

var canceled_call : Callable
var confirmed_call : Callable

func prompt_confirmation(header_text : String, description_text : String, canceled : Callable, confirmed : Callable):
	visible = true
	header.text = header_text + "?"
	description.text = description_text
	
	confirm_button.text = header_text
	
	canceled_call = canceled
	confirmed_call = confirmed
	
	cancel_button.disabled = false
	confirm_button.disabled = false

func _on_confirmed():
	if not confirmed_call == null:
		confirmed_call.call()
	
	_cleanup()

func _on_canceled():
	if not canceled_call == null:
		canceled_call.call()
	
	_cleanup()

func _cleanup():
	visible = false
	header.text = "EMPTY"
	description.text = "EMPTY"
	
	confirm_button.text = "EMPTY"
	
	cancel_button.disabled = true
	confirm_button.disabled = true
