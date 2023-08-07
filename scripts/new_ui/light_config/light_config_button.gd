class_name LightConfigButton extends MarginContainer

var light_strength : float
var light_angle : int
var light_color : Color

#@onready var light_strength_label = $Panel/VBoxContainer/VBoxContainer/MarginContainer4/HBoxContainer/CenterContainer/light_strength_label
#@onready var light_angle_label = $Panel/VBoxContainer/VBoxContainer/MarginContainer6/HBoxContainer/CenterContainer/light_angle_label
#@onready var miniature_color_display = $Panel/VBoxContainer/VBoxContainer/Button/HBoxContainer2/HBoxContainer/MarginContainer/CenterContainer/miniature_color_display
#@onready var label = $Panel/VBoxContainer/VBoxContainer/Button/HBoxContainer2/HBoxContainer/Label
#@onready var button = $Panel/VBoxContainer/VBoxContainer/Button


@onready var light_strength_label = $Panel/VBoxContainer/VBoxContainer/MarginContainer4/HBoxContainer/CenterContainer/MarginContainer/light_strength_label
@onready var light_angle_label = $Panel/VBoxContainer/VBoxContainer/MarginContainer6/HBoxContainer/CenterContainer/MarginContainer/light_angle_label
@onready var miniature_color_display = $Panel/VBoxContainer/VBoxContainer/Button/HBoxContainer2/HBoxContainer/MarginContainer/CenterContainer/inner
@onready var label = $Panel/VBoxContainer/VBoxContainer/Button/HBoxContainer2/HBoxContainer/Label
@onready var button = $Panel/VBoxContainer/VBoxContainer/Button
@onready var texture_rect = $Panel/VBoxContainer/VBoxContainer/Button/HBoxContainer2/HBoxContainer2/MarginContainer/CenterContainer/TextureRect


#@onready var color_picker = $Panel/VBoxContainer/VBoxContainer/MarginContainer/ColorPicker
#@onready var text_edit = $Panel/VBoxContainer/VBoxContainer/MarginContainer2/TextEdit
#@onready var strength_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer4/HBoxContainer/CenterContainer2/MarginContainer/strength_scroll_bar
#@onready var angle_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer6/HBoxContainer/CenterContainer2/MarginContainer/angle_scroll_bar
#@onready var value_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer/MarginContainer/value_scroll_bar
@onready var color_picker = $Panel/VBoxContainer/VBoxContainer/MarginContainer/ColorPicker
@onready var text_edit = $Panel/VBoxContainer/VBoxContainer/MarginContainer2/TextEdit
@onready var strength_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer/strength_scroll_bar
@onready var angle_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer6/HBoxContainer/MarginContainer/angle_scroll_bar
@onready var value_scroll_bar = $Panel/VBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/value_scroll_bar

var expand_icon = preload("res://assets/ui/UI_V2/LightCustomizingOptions_V2/ExpandLightCustom_Decrease_V2.svg")
var shrunk_icon = preload("res://assets/ui/UI_V2/LightCustomizingOptions_V2/ExpandLightCustom_Increase_V2.svg")

var connected_light : NewLightWidget

func set_button_name(new_name : String):
	label.text = new_name

func update_light_strength(new_strength : float):
	light_strength = new_strength
	
	var text = str(light_strength)
	if not text.length() == 1:
		text = text.substr(1)
	
	light_strength_label.text = text
	
	if not connected_light == null:
		connected_light.set_color_strength(light_strength)

func update_light_angle(new_angle : float):
	light_angle = new_angle
	
	light_angle_label.text = str(light_angle) + "°"
	
	if not connected_light == null:
		connected_light.set_light_angle(light_angle)

func update_light_color(new_color : Color):
	light_color = new_color
	
	var adjusted_light_color = Color(new_color.r, new_color.g, new_color.b, 1)
	adjusted_light_color.v = max(adjusted_light_color.v, 0.5)
	
	miniature_color_display.self_modulate = adjusted_light_color
	
	if not connected_light == null:
		connected_light._set_color_UTIL(light_color)

func set_color_from_light(light : NewLightWidget):
	light_color = light.color
	light_strength = light.get_color_strength()
	light_angle = light.get_light_angle()
	color_picker.color = light_color
	miniature_color_display.self_modulate = light_color
	text_edit.text = "#" + light_color.to_html()
	
	strength_scroll_bar.value = light_strength * 1000.0
	angle_scroll_bar.value = light_angle
	value_scroll_bar.value = (-light_color.v + 1) * 100.0
	
	set_connected_light(light)

func set_toggle_group(group : ExclusiveToggleGroup):
	group.register_button(button)

func set_connected_light(light : NewLightWidget):
	connected_light = light

func on_button_open():
	#print("light made material")
	connected_light.make_material()
	texture_rect.texture = expand_icon
	#connected_light.controller.select_light(null)
	pass

func on_button_close():
	#print("light made immaterial")
	connected_light.make_immaterial()
	connected_light.controller.force_hide_lights()
	texture_rect.texture = shrunk_icon
	pass

func delete_light():
	connected_light.controller.select_light(null)
	connected_light.queue_free()
	queue_free()
