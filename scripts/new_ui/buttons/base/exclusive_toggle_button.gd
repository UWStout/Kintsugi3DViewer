class_name ExclusiveToggleButton extends ToggleButton

@export var toggle_group : ExclusiveToggleGroup

func _ready():
	if not toggle_group == null:
		toggle_group.register_button(self)

	if _start_toggled and not _is_toggled:
		toggle_group.make_button_active(self)
	
	super._ready()

func _pressed():
	if toggle_group == null:
		return
	
	if not _is_toggled:
		toggle_group.make_button_active(self)
	else:
		toggle_group.make_button_inactive(self)

func _on_toggle_on():
	if not toggle_group == null:
		if not toggle_group.can_toggle_off_all:
			disabled = true
	
	await super._on_toggle_on()

func _on_toggle_off():
	disabled = false
	await super._on_toggle_off()
