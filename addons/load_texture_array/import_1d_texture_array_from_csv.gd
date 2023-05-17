@tool
extends EditorImportPlugin

func _get_importer_name():
	return "1d_texture_array_from_csv"

func _get_visible_name():
	return "1D Texture Array from CSV"
	
func _get_recognized_extensions():
	return ["csv"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "ImageTexture"
	
func _get_priority():
	return 1.0
	
func _get_import_order():
	return 0
	
func _get_preset_count():
	return 1

func _get_preset_name(i):
	return "Default"

func _get_import_options(path, i):
	return []

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
		
	var width = 0;
	var count = 0;
	var data = PackedFloat32Array()
	while (!file.eof_reached()):
		var red = file.get_line().split(',')
		var green = file.get_line().split(',')
		var blue = file.get_line().split(',')
		
		if (width == 0):
			width = red.size() - 1 # red, green, blue must all have the same length
			# ignore the first element of every line, which is just the row header
		
		if (red.size() >= 2):
			for i in width: 
				data.append(float(red[i + 1]))
				data.append(float(green[i + 1]))
				data.append(float(blue[i + 1]))
			count += 1
	file.close()
	
	
	var img = Image.create_from_data(width, count, false, Image.FORMAT_RGBF, data.to_byte_array())
	print(img.get_width())
	print(img.get_height())
	var texture = ImageTexture.create_from_image(img)
	print("%s.%s" % [save_path, _get_save_extension()])
	var error = ResourceSaver.save(texture, "%s.%s" % [save_path, _get_save_extension()]);
	print(error)
	return error	
	
#	var images = []
#	while (!file.eof_reached()):
#		var red = file.get_line().split(',')
#		var green = file.get_line().split(',')
#		var blue = file.get_line().split(',')
#
#		if (red.size() >= 2):
#			# ignore the first element of every line, which is just the row header
#			var img = Image.create(red.size() - 1, 1, false, Image.FORMAT_RGB8)
#
#			for i in red.size() - 1: # red, green, blue must all have the same length
#				img.set_pixel(i, 0, Color(float(red[i + 1]), float(green[i + 1]), float(blue[i + 1])))
#
#			images.push_back(img)
#	file.close()
#
#	var textureArray = Texture2DArray.new()
#	textureArray.create_from_images(images)
#	print(textureArray.get_width())
#	print(textureArray.get_height())
#	print("%s.%s" % [save_path, _get_save_extension()])
#	var error = ResourceSaver.save(textureArray, "%s.%s" % [save_path, _get_save_extension()]);
#	print(error)
#	return error
