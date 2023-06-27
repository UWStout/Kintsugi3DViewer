extends FileDialog

class_name ScreenshotFileDialog

var current_image_to_save : Image = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_confirmed():
	if not current_image_to_save == null:
		current_image_to_save.save_png(current_path + ".png")
		current_image_to_save = null

func give_image(image : Image):
	current_image_to_save = image
	pass
