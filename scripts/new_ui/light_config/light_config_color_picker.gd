extends ColorPicker

@onready var light_config_button = $"../../../../.."
@onready var text_edit = $"../../MarginContainer2/TextEdit"


func _on_color_changed(color):
	light_config_button.update_light_color(color)
	text_edit.text = "#" + color.to_html()

func change_color_from_text_edit(new_color : Color):
	color = new_color
	light_config_button.update_light_color(color)
