class_name ExclusiveToggleButton extends ToggleButton

@export var toggle_group : ExclusiveToggleGroup

func _ready():
	if not toggle_group == null:
		toggle_group.register_button(self)
	if _start_toggled:
		toggle_group.make_button_active(self)
	
	super._ready()

func _pressed():
	if toggle_group == null:
		return
	
	if not _is_toggled:
		toggle_group.make_button_active(self)
	else:
		toggle_group.make_button_inactive(self)

func display_active():
	pass

func display_inactive():
	pass
