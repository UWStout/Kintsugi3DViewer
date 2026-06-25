# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

@export var main_light : DirectionalLight3D
@export var backlight : DirectionalLight3D
@export var world_environment : WorldEnvironment

@export var full_light_icon = preload("res://assets/UI 2D/light_full.png")
@export var ambient_light_icon = preload("res://assets/UI 2D/light_ambient.png")
@export var no_light_icon = preload("res://assets/UI 2D/light_none.png")

# state 0 is full lighting (only main and backlight on)
# state 1 is ambient lighting (only ambient light in)
# state 2 is no lighting (no lights on)
var state : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	state = (state + 1) % 3
	
	if state == 0:
		main_light.visible = true
		backlight.visible = true
		world_environment.environment.ambient_light_energy = 0
		icon = full_light_icon
	elif state == 1:
		main_light.visible = false
		backlight.visible = false
		world_environment.environment.ambient_light_energy = 1
		icon = ambient_light_icon
	else:
		main_light.visible = false
		backlight.visible = false
		world_environment.environment.ambient_light_energy = 0
		icon = no_light_icon
