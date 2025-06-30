extends ExtendedButton

@export var artifacts_controller : ArtifactsController
@export var filetype_warning : Control

func _pressed():
	
	var dialog = FileDialog.new()
	#dialog.set_window_title("Pick a file, any file")
	dialog.add_filter("*.glb", "GLB Files")
	dialog.add_filter("*.gltf", "GLTF Files")
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	dialog.popup(calculate_center_rect())
	
	#dialog.popup(Rect2i(0, 100, 300, 300))
	add_child(dialog)

	## has_result() returns false as long as the window's still up
	#await dialog.has_result
	
	dialog.file_selected.connect(func(result : String):
		if result.ends_with(".glb") or result.ends_with(".gltf"):
			artifacts_controller._open_artifact_through_file(result)
			LocalSaveData._save_model(result.get_slice("/", (result.get_slice_count("/")-2)), result)
		else:
			filetype_warning.visible = true
			filetype_warning.mouse_filter = Control.MOUSE_FILTER_STOP
			
	)

func calculate_center_rect():
	var window_width
	var window_height
	if (UiScaling.resolution == "high"):
		window_width = DisplayServer.window_get_size().x/UiScaling.high_resolution
		window_height = DisplayServer.window_get_size().y/UiScaling.high_resolution
	else:
		window_width = DisplayServer.window_get_size().x
		window_height = DisplayServer.window_get_size().y
	
	var size_x : int = 0.65 * window_width
	var size_y : int = 0.65 * window_height
	
	var rect_start_x = (window_width - size_x) / 2
	var rect_start_y = (window_height - size_y) / 2
	
	return Rect2i(rect_start_x, rect_start_y, size_x, size_y)
	pass
