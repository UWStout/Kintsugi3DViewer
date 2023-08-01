class_name ContextMenu extends Control

@export var connected_button : ExclusiveToggleButton

func on_context_expanded():
	pass


func on_context_shrunk():
	if not connected_button == null and connected_button._is_toggled:
		connected_button._pressed()
