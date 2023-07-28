extends ExclusiveToggleButton

@export var parent_panel : ExpandingPanel
@export var parent_config_button : LightConfigButton

func _on_toggle_on():
	parent_panel.expand()
	parent_config_button.on_button_open()
	
	super._on_toggle_on()

func _on_toggle_off():
	parent_panel.shrink()
	parent_config_button.on_button_close()
	
	super._on_toggle_off()
