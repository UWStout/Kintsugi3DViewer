extends VScrollBar

@onready var color_picker = $"../../../ColorPicker"

func _value_changed(new_value):
	color_picker.color.v = (100 - new_value) / 100.0
	
	color_picker._on_color_changed(color_picker.color)
