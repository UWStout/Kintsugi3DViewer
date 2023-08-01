extends HScrollBar

@onready var light_config_button = $"../../../../../../.."


func _value_changed(new_value):
	light_config_button.update_light_angle(new_value)
