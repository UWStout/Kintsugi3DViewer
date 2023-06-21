extends StaticBody3D

class_name MovableSpotlight

var controller : MovableLightingController

var angle : float = 0
var radius : float = 0
var height : float = 0

var is_dragging = false

var connected_light : DirectionalLight3D

# Always look towards the world origin, which is approximately the
# angle of the world light
func _process(delta):
	look_at(Vector3(0,0,0))

# modify the material to look like the light it represents
func set_color(new_color : Color, energy_percent : float):
	if not $mesh == null:
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = new_color
		mat.albedo_color.a = (clampf(energy_percent, 0.5, 1))
		mat.emission_enabled = true
		mat.emission = new_color
		mat.emission_energy_multiplier = 1
		
		$mesh.set_surface_override_material(0, mat)

func update_angle(new_angle : float):
	angle = fmod(new_angle, 360.0)
	
	if not connected_light == null:
		connected_light.rotation_degrees.y = angle
	
	position = Vector3(sin(deg_to_rad(angle)) * radius, height, cos(deg_to_rad(angle)) * radius)

func _input(event):
	if not controller == null and controller.selected_light == self:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
		
		if event is InputEventMouseMotion and is_dragging:
			if not controller.camera == null and controller.camera.camera.is_position_in_frustum(controller.get_rig_center()):
				controller.camera.do_move_in_frame = false
				
				var rig_center_screen_space = controller.camera.camera.unproject_position(controller.get_rig_center())
				var rig_forward_screen_space = controller.camera.camera.unproject_position(controller.get_rig_forward())
				
				var rig_y_dist = rig_forward_screen_space.y - rig_center_screen_space.y
				var rig_x_dist = rig_forward_screen_space.x - rig_center_screen_space.x
				
				var rig_diff_angle = rad_to_deg(atan2(rig_y_dist, rig_x_dist))
				
				var y_dist = rig_center_screen_space.y - event.position.y
				var x_dist = rig_center_screen_space.x - event.position.x
				
				var angle = rad_to_deg(atan2(y_dist, x_dist))
				var result = angle - rig_diff_angle - 180
				
				var scale_factor = sign(controller.camera.rotationPoint.rotation_degrees.x)
				
				update_angle(result * scale_factor)
	pass

func make_visible():
	visible = true
	collision_layer = 2
	collision_mask = 2
	pass
	
func make_not_visible():
	visible = false
	collision_layer = 0
	collision_mask = 0
	pass
