class_name ToggleButton extends ExtendedButton

@export var _start_toggled : bool = false
var _is_toggled : bool = false

@export var toggled_on_style : StyleBox
@export var toggled_on_hover_style : StyleBox

@export var toggled_off_style : StyleBox
@export var toggled_off_hover_style : StyleBox

func _ready():
	set_normal_style(toggled_off_style)
	set_hover_style(toggled_off_hover_style)
	set_pressed_style(toggled_on_style)
	
	if _start_toggled and not _is_toggled:
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
	_display_toggled_on()

func _on_toggle_off():
	_display_toggled_off()

func _display_toggled_on():
	set_normal_style(toggled_on_style)
	set_disabled_style(toggled_on_style)
	set_hover_style(toggled_on_hover_style)
	set_pressed_style(toggled_off_style)

func _display_toggled_off():
	set_normal_style(toggled_off_style)
	set_hover_style(toggled_off_hover_style)
	set_pressed_style(toggled_on_style)