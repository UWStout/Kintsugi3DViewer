extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	print("hello")
	take_screenshot()
	pass

func take_screenshot():
	#var img = get_viewport().get_texture().get_image()
	#img.save_png("user://screenshot.png")
	pass
