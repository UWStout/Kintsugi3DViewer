extends EditorInspectorPlugin

func _can_handle(object):
	return object is Texture2DArrayLoader
	

func _parse_begin (object):
	if object is Texture2DArrayLoader:
		var refreshButton = Button.new()
		refreshButton.text = "Refresh Texture Array"
		refreshButton.pressed.connect(func():
			object.create_from_images(object.imagesToLoad)
			print("Created texture array from images"))
		add_custom_control(refreshButton)
