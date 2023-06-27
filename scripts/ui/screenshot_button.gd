extends Button

@export var ui_root : NodePath
@export var environment_controller : EnvironmentController
@export var save_window : ScreenshotFileDialog

var did_take_screenshot : bool = false
var do_take_screenshot_frame_count : int = -1

# If a screenshot is queued to be taken,
# wait a few frames to make sure everything that shouldn't be on the screen is gone
# and then take the screenshot, and then wait a few frames to
# restore the UI or other hidden screen elements
func _process(delta):
	if do_take_screenshot_frame_count > 0:
		do_take_screenshot_frame_count -= 1
	elif do_take_screenshot_frame_count == 0:
		if did_take_screenshot:
			did_take_screenshot = false
			show_screen_distractions()
			do_take_screenshot_frame_count = -1
		else:
			take_screenshot()
			did_take_screenshot = true
			do_take_screenshot_frame_count = 1
		pass
	
	pass

func _pressed():
	hide_screen_distractions()
	do_take_screenshot_frame_count = 1

func take_screenshot():
	var img = get_viewport().get_texture().get_image()
	if not save_window == null:
		save_window.visible = true
		save_window.give_image(img)
	#img.save_png("user://screenshot.png")

func hide_screen_distractions():
	if not ui_root == null:
		get_node(ui_root).visible = false
	if not environment_controller == null:
		environment_controller.stop_customizing_lights()
	
func show_screen_distractions():
	if not ui_root == null:
		get_node(ui_root).visible = true
