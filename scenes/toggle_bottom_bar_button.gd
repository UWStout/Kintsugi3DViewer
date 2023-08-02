extends ExclusiveToggleButton

@export var panel : ExpandingPanel

func _on_toggle_on():
	panel.expand()

func _on_toggle_off():
	panel.shrink()
