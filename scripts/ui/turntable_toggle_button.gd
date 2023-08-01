class_name TurntableButton extends Button

var _is_toggled : bool = false

var _is_grabbed = false

@export var _return_to_default_orientation : bool = true
@export var _lerp_speed : float = 0.5
@export var _scene_camera_rig : CameraRig
@export var _artifacts_controller : ArtifactsController
@export var _customize_lighting_button : CustomizeLightingButton

func _pressed():
	_customize_lighting_button.override_stop_customizing()
	
	if _is_toggled:
		_is_toggled = false
		text = "Rotate Object: OFF"
		_scene_camera_rig.rig_enabled = true
	else:
		_is_toggled = true
		text = "Rotate Object: ON"
		_scene_camera_rig.rig_enabled = false


func _input(event):
	if not _is_toggled or _artifacts_controller.loaded_artifact == null or not _artifacts_controller.loaded_artifact.load_finished:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_grabbed = true
		else:
			_is_grabbed = false
	
	if event is InputEventMouseMotion and _is_grabbed:
		
		var yaw_val = event.relative.x * 0.01
		var pitch_val = event.relative.y * 0.01
		
		var artifact = _artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.rotated(Vector3.UP, yaw_val).orthonormalized()
		artifact.transform.basis = artifact.transform.basis.rotated(_scene_camera_rig.camera.global_transform.basis.x, pitch_val).orthonormalized()

func _process(delta):
	#if not _is_toggled:
		#return_to_default_orientation()
		#lerp_to_default_orientation(delta * _lerp_speed)
	pass

func return_to_default_orientation():
	if not _artifacts_controller.loaded_artifact == null:
		_artifacts_controller.loaded_artifact.transform.basis = Basis.IDENTITY
	pass

func lerp_to_default_orientation(delta : float):
	if not _artifacts_controller.loaded_artifact == null and not _artifacts_controller.loaded_artifact.transform.basis.is_equal_approx(Basis.IDENTITY):
		var artifact = _artifacts_controller.loaded_artifact
		
		artifact.transform.basis = artifact.transform.basis.slerp(Basis.IDENTITY, delta).orthonormalized()

func force_quit():
	_is_toggled = false
	_is_grabbed = false
	text = "Turntable: OFF"
	_scene_camera_rig.rig_enabled = true
