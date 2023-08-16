# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

@export var ui_root : NodePath
@export var environment_controller : EnvironmentController
@export var light_selection_ui : LightSelectionUI

func _pressed():
	hide_screen_distractions()
	await get_tree().create_timer(0.1).timeout
	take_screenshot()
	show_screen_distractions()

func take_screenshot():
	var img = get_viewport().get_texture().get_image()
	
	var os = OS.get_name()
	
	match OS.get_name():
		"Windows", "UWP":
			save_on_desktop(img)
		"macOS":
			save_on_desktop(img)
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			save_on_desktop(img)
		"Android":
			save_on_mobile(img)
		"iOS":
			save_on_mobile(img)
		"Web":
			save_on_web(img)
		_:
			print("could not save screenshot on this device!")

func hide_screen_distractions():
	if not ui_root == null:
		get_node(ui_root).visible = false
	if not light_selection_ui == null:
		light_selection_ui.button_group.close_all_buttons()
	
func show_screen_distractions():
	if not ui_root == null:
		get_node(ui_root).visible = true

func save_on_desktop(image : Image):
	var Dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	if Dir == null:
		printerr("There was an error attempting to acces the system's pictures directory!")
		return
	
	if not Dir.dir_exists("Kintsugi"):
		var error = Dir.make_dir("Kintsugi")
		
		if error:
			printerr("There was an error attempting to create Pictures/Kintsugi directory")
			return
	
	Dir = Dir.open(Dir.get_current_dir(false).path_join("Kintsugi"))
	if Dir == null:
		print("There was an error opening the Pictures/Kintsugi directory")
		return
	
	var file_name = "screenshot.png"
	var file_num = 0
	while Dir.file_exists(file_name):
		file_num += 1
		file_name = "screenshot(" + str(file_num) + ").png"
	
	image.save_png(Dir.get_current_dir(false).path_join(file_name))
	print("saved file " + file_name + " to directory Pictures/Kintsugi")

func save_on_mobile(image : Image):
	var has_permissions: bool = false

	while not has_permissions:
		var permissions: PackedStringArray = OS.get_granted_permissions()
		
		if not permissions.has("android.permission.READ_EXTERNAL_STORAGE") \
			or not permissions.has("android.permission.WRITE_EXTERNAL_STORAGE"):
			OS.request_permissions()
			await get_tree().create_timer(1).timeout
		else:
			has_permissions = true
	
	var Dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	if Dir == null:
		printerr("There was an error attempting to acces the system's pictures directory!")
		return
	
	if not Dir.dir_exists("Kintsugi"):
		var error = Dir.make_dir("Kintsugi")
		
		if error:
			printerr("There was an error attempting to create Pictures/Kintsugi directory")
			return
	
	Dir = Dir.open(Dir.get_current_dir(false).path_join("Kintsugi"))
	if Dir == null:
		print("There was an error opening the Pictures/Kintsugi directory")
		return
	
	var file_name = "screenshot.png"
	var file_num = 0
	while Dir.file_exists(file_name):
		file_num += 1
		file_name = "screenshot(" + str(file_num) + ").png"
	
	image.save_png(Dir.get_current_dir(false).path_join(file_name))

func save_on_web(image : Image):
	var buffer = image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "screenshot.png")
