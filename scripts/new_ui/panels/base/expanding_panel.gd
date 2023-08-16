# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExpandingPanel extends Panel

enum DIRECTION {VERTICAL, HORIZONTAL}

@export var expand_direction : DIRECTION = DIRECTION.HORIZONTAL
@export var minimized_size : float = 0
@export var maximized_size : float = 100
@export var animation_speed : float = 0.01
@export var animation_curve : Curve

var _expanding :bool = false
var _shrinking : bool = false

var is_expanded : bool = false

func _get_direction_vector():
	if expand_direction == DIRECTION.VERTICAL:
		return Vector2(0, 1)
	if expand_direction == DIRECTION.HORIZONTAL:
		return Vector2(1, 0)

func expand():
	if is_expanded or _expanding:
		return
	
	_expanding = true
	_shrinking = false
	
	var x = 0
	while _expanding and x < 1:
		x += animation_speed
		await get_tree().create_timer(0.01).timeout
		var panel_size = lerpf(minimized_size, maximized_size, animation_curve.sample(x))
		
		if expand_direction == DIRECTION.HORIZONTAL:
			custom_minimum_size.x = panel_size
		else:
			custom_minimum_size.y = panel_size
		#custom_minimum_size = _get_direction_vector() * panel_size
	
	if _expanding:
		_expanding = false
		is_expanded = true
		#custom_minimum_size = _get_direction_vector() * maximized_size
		if expand_direction == DIRECTION.HORIZONTAL:
			custom_minimum_size.x = maximized_size
		else:
			custom_minimum_size.y = maximized_size

func shrink():
	if not is_expanded or _shrinking:
		return
	
	_expanding = false
	_shrinking = true
	
	var x = 0
	while _shrinking and x < 1:
		x += animation_speed
		await get_tree().create_timer(0.01).timeout
		var panel_size = lerpf(maximized_size, minimized_size, animation_curve.sample(x))
		if expand_direction == DIRECTION.HORIZONTAL:
			custom_minimum_size.x = panel_size
		else:
			custom_minimum_size.y = panel_size
		#custom_minimum_size = _get_direction_vector() * panel_size
	
	if _shrinking:
		_shrinking = false
		is_expanded = false
		#custom_minimum_size = _get_direction_vector() * minimized_size
		if expand_direction == DIRECTION.HORIZONTAL:
			custom_minimum_size.x = minimized_size
		else:
			custom_minimum_size.y = minimized_size

func is_animating():
	return _expanding or _shrinking

