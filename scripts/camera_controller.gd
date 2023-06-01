# Camera controller script

extends Camera3D

@export_category("Camera Controller")
@export var controlEnabled: bool = true
@export var rotationpoint: Node3D

@export_group("Drag Control")
@export var dragModifier: float = 0.01

@export_group("Rotation Control")
@export var rotationModifier: float = 0.01
@export var minAngle: float = 6
@export var maxAngle: float = 174

@export_group("Dolly Control")
@export var zoomModifier: float = 1
@export var minZoomDistance: float = 1
@export var maxZoomDistance: float = 100
@export var distanceSpeed: float = 0.1

@export_group("Zoom Control")
@export var maxFov: float = 120
@export var minFov: float = 10
@export var fovModifier: float = 1
@export var fovSpeed: float = 0.1

@export_group("Raycasting")
@export var ray_distance : float = 1000
@export_flags_2d_physics var collision_mask

var dragCamera: bool = false
var rotateCamera: bool = false

var targetDistance: float
var targetFov: float

var annotation_target_position: Vector3
var do_move_to_target_pos: bool = false
var annotation_target_distance: float
var do_zoom_to_target_distance: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check for invalid rotation point parameter
	if (! is_instance_valid(rotationpoint)):
		push_error("Camera controller on node %s has an invalid or unset rotation point!" % get_path())
		
	look_at(rotationpoint.position)
	rotationpoint.rotation = rotation
	
	targetDistance = position.distance_to(rotationpoint.position)
	targetFov = fov
	
	# Set defaults for the annotation's auto zoom, pan, and rotate
	annotation_target_position = rotationpoint.global_position
	annotation_target_distance = targetDistance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_target_distance : float = targetDistance
	if do_zoom_to_target_distance:
		current_target_distance = annotation_target_distance
	
	var current_distance := position.distance_to(rotationpoint.position)
	var delta_distance := (current_target_distance - current_distance) * distanceSpeed
	position += (position - rotationpoint.position).normalized() * delta_distance
	
	if do_zoom_to_target_distance and abs(current_distance - current_target_distance) <= 0.01:
		do_zoom_to_target_distance = false
		targetDistance = annotation_target_distance
	
	fov += (targetFov - fov) * fovSpeed
	
#	# LERP to the current annotation_target_position (the annotation / detail clicked by the viewer)
	if do_move_to_target_pos:
		var deltaPos = lerp(rotationpoint.global_position, annotation_target_position, delta * 3) - rotationpoint.global_position

		rotationpoint.global_position += deltaPos
		global_position += deltaPos

		if rotationpoint.global_position.distance_to(annotation_target_position) <= 0.001:
			rotationpoint.global_position = annotation_target_position
			do_move_to_target_pos = false

func enable_camera():
	controlEnabled = true

func disable_camera():
	controlEnabled = false
	detatch_control()

# Equivelant to the usage of DisableCamera() in Unity implementation
func detatch_control():
	dragCamera = false
	rotateCamera = false

func _input(event):
	if not event is InputEventMouse:
		return
	
	if not controlEnabled:
		return
		
	
	# DEBUG SPACE FOR ANNOTATION CLICKING
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		cast_ray_to_world()
	
	if event is InputEventMouseButton:
		# Left Click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragCamera = false
				rotateCamera = true
			else:
				rotateCamera = false
				
		# Right Click
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				rotateCamera = false
				dragCamera = true
				do_move_to_target_pos = false
			
			else:
				dragCamera = false
		
		if event.is_command_or_control_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				targetFov = max(minFov, targetFov - fovModifier)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				targetFov = min(maxFov, targetFov + fovModifier)
				
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if targetDistance >= minZoomDistance:
					targetDistance -= zoomModifier
				
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if targetDistance <= maxZoomDistance:
					targetDistance += zoomModifier
			
	
	if event is InputEventMouseMotion:
		if dragCamera:
			var offset := Vector3(-event.relative.x, event.relative.y, 0)
			translate_object_local(offset * dragModifier)
			rotationpoint.translate_object_local(offset * dragModifier)
			
			AnnotationsManager.change_selected_annotation(null)
		
		if rotateCamera:
			var basis := global_transform.basis
			var origin := global_transform.origin - rotationpoint.position
			
			# Rotate on x axis
			basis = basis.rotated(Vector3.UP, -event.relative.x * rotationModifier)
			origin = origin.rotated(Vector3.UP, -event.relative.x * rotationModifier)
			
			# Rotate on y axis
			var yLimited: bool = false
			var forward := -transform.basis.z
			if forward.angle_to(Vector3.UP) < (minAngle * PI / 180):
				if -event.relative.y >= 0:
					yLimited = true
			elif forward.angle_to(Vector3.UP) > (maxAngle * PI / 180):
				if -event.relative.y <= 0:
					yLimited = true
			
			if not yLimited:
				basis = basis.rotated(global_transform.basis.x, -event.relative.y * rotationModifier)
				origin = origin.rotated(global_transform.basis.x, -event.relative.y * rotationModifier)
			
			# Rebuild transform from basis and origin
			global_transform = Transform3D(basis, rotationpoint.position + origin)
			look_at(rotationpoint.position)
			rotationpoint.rotation = rotation;

func cast_ray_to_world():
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position_screen = get_viewport().get_mouse_position()
	var mouse_position_world = project_ray_origin(mouse_position_screen)
	
	var ray_end = mouse_position_world + project_ray_normal(mouse_position_screen) * ray_distance
	
	var ray_query = PhysicsRayQueryParameters3D.create(mouse_position_world, ray_end, collision_mask)
	var ray_result = space_state.intersect_ray(ray_query)
	
	if ray_result:
		var annotation = ray_result["collider"]
		annotation.on_annotation_clicked()
		
		annotation_target_position = annotation.get_focus_point().global_position
		do_move_to_target_pos = annotation.get_focus_point().do_pan_to_annotation
		
		annotation_target_distance = annotation.get_focus_point().annotation_distance
		do_zoom_to_target_distance = annotation.get_focus_point().do_zoom_to_annotation
