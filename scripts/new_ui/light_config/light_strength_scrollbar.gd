extends HScrollBar

@onready var light_config_button = $"../../../../../../../.."

func _value_changed(new_value):
	new_value = new_value / 1000.0
	new_value = snapped(new_value, 0.001)
	light_config_button.update_light_strength(new_value)
