class_name ExclusiveToggleGroup extends Node

@export var can_toggle_off_all : bool = true

var connected_buttons : Array[ExclusiveToggleButton]
var active_button : ExclusiveToggleButton = null

func register_button(new_button : ExclusiveToggleButton):
	if not connected_buttons.has(new_button):
		connected_buttons.push_back(new_button)

func make_button_active(button : ExclusiveToggleButton):
	if not connected_buttons.has(button):
		return
	
	if active_button == null:
		active_button = button
		active_button.display_active()
		active_button.toggle_on()
		return
	
	await active_button.toggle_off()
	active_button.display_inactive()

	active_button = button
	active_button.display_active()
	active_button.toggle_on()

func make_button_inactive(button : ExclusiveToggleButton):
	if not connected_buttons.has(button) or not active_button == button:
		return
	
	if can_toggle_off_all:
		active_button = null
		button.display_inactive()
		button.toggle_off()

