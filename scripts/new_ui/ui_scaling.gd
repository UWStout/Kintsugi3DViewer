extends Control

var base_resolution = Vector2(1142, 648)
var max_resolution = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().connect("size_changed", Callable(self, "on_window_size_changed"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_window_size_changed():
	print("window size changed")
	update_ui_scale()


func update_ui_scale():
	var screen_size = DisplayServer.window_get_size()
	print("SCREEN SIZE:", screen_size)
	print("BASE RESOLUTION:", base_resolution)
	var scale_x = screen_size.x/base_resolution.x
	var scale_y = screen_size.y/base_resolution.y
	var scale = min(scale_x, scale_y)
	print("SCALE:", scale_x, ", ", scale_y)
	scale = clampf(scale, 1.0, max_resolution)
	print("SCALE:", scale)
	self.size = Vector2(screen_size.x*scale, screen_size.y*scale)
	print("resized to", self.size)
	
