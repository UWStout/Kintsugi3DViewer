class_name LightSelectionUI extends ContextMenu

@export var light_config_button : PackedScene

@onready var v_box_container = $ScrollContainer/VBoxContainer
@onready var new_light_button = $ScrollContainer/VBoxContainer/new_light_button
@onready var button_group = $button_group

func on_context_expanded():
	pass

func on_context_shrunk():
	button_group.close_all_buttons()

func create_button_for_light(light : NewLightWidget):
	var new_button = light_config_button.instantiate()
	
	var num_children = v_box_container.get_children().size()
	v_box_container.add_child(new_button)
	new_button.set_button_name("Light")
	new_button.set_toggle_group(button_group)
	
	new_button.set_color_from_light(light)

func clear_buttons():
	for i in range(1, v_box_container.get_children().size()):
		v_box_container.get_child(i).queue_free()
