extends LineEdit

@onready var color_picker = $"../../MarginContainer/ColorPicker"

func is_hex(text : String):
	if not text.length() == 7:
		return false
	
	if not text.begins_with("#"):
		return false
	
	for char_1 in text.substr(1).to_upper():
		var is_char_valid : bool = false
		for char_2 in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F"]:
			if char_1 == char_2:
				is_char_valid = true
		
		if not is_char_valid:
			return false
	
	return true

func _on_text_changed(new_text):
	if is_hex(text):
		color_picker.change_color_from_text_edit(Color.html(text))

func _on_focus_exited():
	if not is_hex(text):
		text = "#" + color_picker.color.to_html(false)
