# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

@export var camera : CameraRig

@onready var flashlight_off_icon = preload("res://assets/UI 2D/flashlight_off.png")
@onready var flashlight_on_icon = preload("res://assets/UI 2D/flashlight_on.png")

var is_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	is_on = not is_on
	
	if(is_on):
		icon = flashlight_on_icon
		camera.enable_flashlight()
	else:
		icon = flashlight_off_icon
		camera.disable_flashlight()
