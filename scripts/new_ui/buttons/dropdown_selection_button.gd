class_name DropdownSelectionButton extends ExclusiveToggleButton

@onready var title_label = $HBoxContainer/MarginContainer/title_label
@onready var description_label = $HBoxContainer/description_label

var connected_button : DropdownButton
var index : int = -1

func initialize_button(title : String, description : String, option_index : int, button_group : ExclusiveToggleGroup, dropdown_button : DropdownButton):
	title_label.text = title
	if not description.is_empty():
		description_label.text = "- " + description
	button_group.register_button(self)
	connected_button = dropdown_button
	index = option_index

func _on_toggle_on():
	connected_button.select_option(index)
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()
