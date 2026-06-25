# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name OnOffButton extends ToggleButton

@export var sliding_circle : Control

@export var do_animate : bool = true
@export var animate_speed : float = 0.2
@export var animation_curve : Curve
@export var on_color : Color = Color(.85, .85, .85, 1)
@export var off_color : Color = Color(.3, .3, .3, 1)

var _is_animating : bool = false

func _on_toggle_on():
	if _is_animating:
		return
	
	if do_animate:
		animate_button()
	else:
		sliding_circle.position.x = 50
		sliding_circle.modulate = on_color
	
	super._on_toggle_on()

func _on_toggle_off():
	if _is_animating:
		return
	
	if do_animate:
		animate_button()
	else:
		sliding_circle.position.x = 0
		sliding_circle.modulate = off_color
	
	super._on_toggle_off()

func animate_button():
	_is_animating = true
	
	var direction : int = 0
	var start_pos : int = sliding_circle.position.x
	var start_col : Color = Color()
	var end_col : Color = Color()
	if _is_toggled:
		direction = 1
		start_col = off_color
		end_col = on_color
		start_pos = 0
	else:
		direction = -1
		start_col = on_color
		end_col = off_color
		start_pos = 50
	
	var progress = 0
	while progress < 1:
		progress += animate_speed
		await get_tree().create_timer(0.01).timeout
		var new_x = lerpf(start_pos, start_pos + direction * 50, animation_curve.sample(progress))
		sliding_circle.position.x = new_x
		sliding_circle.modulate = lerp_color(start_col, end_col, animation_curve.sample(progress))
	
	sliding_circle.position.x = start_pos + direction * 50
	sliding_circle.modulate = end_col
	_is_animating = false

func lerp_color(a : Color, b : Color, t : float) -> Color:
	var returned_color : Color = Color(0, 0, 0, 0)
	returned_color.r = lerpf(a.r, b.r, t)
	returned_color.g = lerpf(a.g, b.g, t)
	returned_color.b = lerpf(a.b, b.b, t)
	returned_color.a = lerpf(a.a, b.a, t)
	return returned_color
