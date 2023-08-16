# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

class_name CustomizeLightingButton

@export var connected_controller : EnvironmentController

@export var turntable_button : TurntableButton

var is_pressed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	turntable_button.force_quit()
	
	if connected_controller == null:
		return
	
	is_pressed = not is_pressed
	
	if is_pressed:
		text = "Stop Customizing"
		connected_controller.begin_customizing_lights()
		pass
	else:
		text = "Customize Lights"
		connected_controller.stop_customizing_lights()
		pass

func override_stop_customizing():
	is_pressed = false
	text = "Customize Lights"
	
	connected_controller.force_hide_lights()
