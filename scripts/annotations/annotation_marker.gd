# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node3D
class_name AnnotationMarker

@export var focus_point : AnnotationFocusPoint
@export var textbox : AnnotationTextboxPannel
@export var textbox_panel : Control   
@export var leader_line : Line2D
@export var sprite : Sprite3D
@export var click_button : Button   

@export var base_button_size : float = 16.0      # button size at reference_distance
@export var reference_distance : float = 5.0      # distance at which base_button_size applies
@export var min_button_size : float = 8.0
@export var max_button_size : float = 128.0

@export var sprite_base_pixel_size : float = 0.01  # Sprite3D's normal Pixel Size value
@export var min_pixel_size : float = 0.002
@export var max_pixel_size : float = 0.02
		  

@export var occlusion_check_enabled : bool = true
@export var occlusion_collision_mask : int = 1  # match whatever layer your scene geometry (podium, models) is on
@export var textbox_offset : Vector2 = Vector2(80, -80)

var camera : Camera3D
var tracking_input: bool = false
var hold_triggered: bool = false
var system_time_held: float = 0.0
var viewing_angle: Vector3
var turn_back_on: bool = false

func _is_occluded() -> bool:
	if not occlusion_check_enabled:
		return false

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		camera.global_position,
		global_position,
		occlusion_collision_mask
	)
	query.exclude = [self]  # don't let the marker's own collider (if any) block itself
	var result = space_state.intersect_ray(query)

	if result:
		# If we hit something, and it's not very close to the marker itself, we're occluded.
		var hit_distance = camera.global_position.distance_to(result["position"])
		var marker_distance = camera.global_position.distance_to(global_position)
		return hit_distance < marker_distance - 0.05  # small tolerance to avoid self-occlusion flicker
	return false

func get_focus_point():
	if not focus_point == null:
		return focus_point
	else:
		printerr(str(name, " has no focus_point!"))
		return null

func get_textbox():
	if not textbox == null:
		return textbox
	else:
		printerr(str(name, " has no textbox!"))
		return null

func _ready():
	camera = get_viewport().get_camera_3d()
	#print("camera found: ", camera)
	if click_button:
		click_button.pressed.connect(on_annotation_clicked)
		click_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if leader_line:
		leader_line.width = 2.0
	determine_offset()
	
	

func determine_offset():
	if textbox_panel and textbox_panel.visible:
		var screen_pos = camera.unproject_position(global_position)
		var screen_center = get_viewport().get_visible_rect().size / 2
		var difference =  screen_pos - screen_center
		textbox_offset = Vector2(80, -80)
		if difference.x <= 0:
			textbox_offset.x *= -1
			textbox_offset.x -= textbox_panel.size.x *1.5
		else: 
			textbox_offset.x += textbox_panel.size.x/2
		if difference.y >= 0:
			textbox_offset.y *= -1
			textbox_offset.y += textbox_panel.size.y/2
		else:
			textbox_offset.y -= textbox_panel.size.y/2

func select_annotation():
	sprite.visible = false
	textbox.visible = true
	click_button.disabled = true
	determine_offset()
	#textbox.global_position = Vector2(global_position.x, global_position.y )

	
func unselect_annotation():	
	sprite.visible = true
	textbox.visible = false
	click_button.disabled = false
	leader_line.clear_points()

func _process(delta):

	camera = get_viewport().get_camera_3d()
	_update_scale()
	_update_screen_position()
	if textbox.visible and Input.is_action_just_pressed("left_click"):
		tracking_input = true
		hold_triggered = false
		system_time_held = 0.0
	if tracking_input and Input.is_action_pressed("left_click"):
		system_time_held += delta
		if system_time_held >= 0.3:
			return
	if Input.is_action_just_released("left_click"):
		if tracking_input and system_time_held < 0.3:
			unselect_annotation()

	

func _update_screen_position():
	if camera == null or click_button == null:
		print("early return - camera:", camera, " button:", click_button)
		return
	var unit_vec = camera.global_position.normalized()
	var theta = acos(unit_vec.dot(viewing_angle.normalized()))
	
	#theta = rad_to_deg(theta)
	
	# Hide if behind the camera
	if camera.is_position_behind(global_position) or (theta >= PI/2 and (camera.global_position.distance_to(global_position) > 0.92)): #and (camera.global_position.distance_to(global_position) > 0.9)
		
		click_button.visible = false
		sprite.visible = false
		if textbox.visible:
			turn_back_on = true
			textbox.visible = false
			leader_line.visible = false
		return
	if turn_back_on:
		textbox.visible = true
		leader_line.visible = true
		turn_back_on = false
	elif not textbox.visible:
		click_button.visible = true
		sprite.visible = true
	var screen_pos = camera.unproject_position(global_position)
	click_button.global_position = screen_pos - click_button.size / 2.0
	if textbox_panel and textbox_panel.visible:
		var textbox_pos = screen_pos + textbox_offset 
		#print(screen_pos)
		textbox_panel.position = textbox_pos
		if leader_line:
			leader_line.visible = true
			
			var button_center = screen_pos
			var difference = button_center - textbox_pos
			var textbox_center =  textbox_pos
			if difference.x >= 0:
				textbox_center += Vector2(textbox_panel.size.x,0)
			if difference.y >= 0:
				textbox_center += Vector2(0,textbox_panel.size.y)	
			leader_line.points = [button_center, textbox_center]

func on_annotation_clicked():
	if textbox.visible == false:	
		AnnotationsManager.change_selected_annotation(self)
	
func _update_scale():
	if camera == null:
		return
	var distance = camera.global_position.distance_to(global_position)
	# Scale the button (2D, screen-space)
	var button_size = base_button_size * (reference_distance / distance)
	button_size = clamp(button_size, min_button_size, max_button_size)

	# Scale the sprite (3D, world-space) 
	if sprite:
		var pixel_size = sprite_base_pixel_size * (distance / reference_distance)
		pixel_size = clamp(pixel_size, min_pixel_size, max_pixel_size)
		sprite.pixel_size = pixel_size
	
			
			
	if click_button:
		click_button.size = Vector2(button_size, button_size)
