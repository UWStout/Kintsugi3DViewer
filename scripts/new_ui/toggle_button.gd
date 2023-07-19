class_name ToggleButton extends Button

@export var _start_toggled : bool = false
var _is_toggled : bool = false

func _ready():
	if _start_toggled:
		toggle_on()

func _pressed():
	if _is_toggled:
		toggle_off()
	else:
		toggle_on()

func toggle_on():
	_is_toggled = true
	await _on_toggle_on()

func toggle_off():
	_is_toggled = false
	await _on_toggle_off()

func _on_toggle_on():
	pass

func _on_toggle_off():
	pass
