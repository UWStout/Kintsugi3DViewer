class_name ArtifactsManager extends Node3D

var active_controller : ArtifactsController
signal active_controller_changed(new_controller: ArtifactsController)

@export var local : LocalArtifactsController
@export var server : ServerArtifactsController

func _ready() -> void:
	set_active_controller(local)

func set_active_controller(controller: ArtifactsController):
	if active_controller == controller:
		return
	active_controller = controller
	emit_signal("active_controller_changed", active_controller)

func toggle_to_local():
	set_active_controller(local)

func toggle_to_server():
	set_active_controller(server)

func _on_environment_changed(new_environment: DisplayEnvironment) -> void:
	if active_controller != null:
		active_controller._on_environment_changed(new_environment)
