extends Control

var base_resolution = Vector2(1142, 648)
var max_resolution = 1.5
var max_scale_x
var max_scale_y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().connect("size_changed", Callable(self, "on_window_size_changed"))
	max_scale_x = base_resolution.x * max_resolution
	max_scale_y = base_resolution.y * max_resolution
	unlock_ui_scale()
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_window_size_changed():
	print("window size changed")
	#update_ui_scale()
	print("SIZE: ", self.size, "VS MAX SIZE: (", max_scale_x, ", ", max_scale_y)
	if ((self.size.x >= max_scale_x) or (self.size.y >= max_scale_y)):
		#pass
		max_ui_scale()
		print("ui scale bigger than 2")
	elif (ProjectSettings.get_setting("display/window/stretch/scale") == max_resolution):
		#pass
		unlock_ui_scale()
		print("unlocked")
	else:
		print("already unlocked, no need to unlock")
	print("PROJECT SETTINGS: ", ProjectSettings.get_setting("display/window/stretch/scale"), ProjectSettings.get_setting("display/window/stretch/mode"))


func max_ui_scale():
	ProjectSettings.set_setting("display/window/stretch/mode", "disabled")
	ProjectSettings.set_setting("display/window/stretch/scale", max_resolution)
	ProjectSettings.save()
func unlock_ui_scale():
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/scale", 1)
	ProjectSettings.save()
	
