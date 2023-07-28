extends Button

@export var light_config_button : LightConfigButton

func _pressed():
	light_config_button.delete_light()
