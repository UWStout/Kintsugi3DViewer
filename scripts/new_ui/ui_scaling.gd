extends Control

var default_resolution = 1
var mac_resolution = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (OS.get_name() == "macOS"):
		ProjectSettings.set_setting("display/window/stretch/scale", mac_resolution)
		ProjectSettings.save()
	else:
		ProjectSettings.set_setting("display/window/stretch/scale", default_resolution)
		ProjectSettings.save()
	print("SCALING SIZE: ", ProjectSettings.get_setting("display/window/stretch/scale"))
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
