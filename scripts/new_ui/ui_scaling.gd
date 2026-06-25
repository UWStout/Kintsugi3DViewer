extends Control

var default_resolution = 1
var high_resolution = 2
var resolution

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if screen height is greater than 1440 pixels. Typically applies to Mac displays, but works on any high-resolution screen.  
	# This should scale up for 4K displays but not 1440p or ultra-wide displays that are 1440 pixels or less vertically.
	if (DisplayServer.screen_get_size().y > 1440):
		get_window().content_scale_factor = high_resolution
		DisplayServer.window_set_size(get_viewport().size * high_resolution)
		resolution = "high"
	else:
		get_window().content_scale_factor = default_resolution
		DisplayServer.window_set_size(get_viewport().size * default_resolution)
		resolution = "default"
	#print(DisplayServer.window_get_size())
	#pass
