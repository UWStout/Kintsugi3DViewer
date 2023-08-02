class_name HideUIButton extends ToggleButton

@export var nodes_to_hide : Array[NodePath]
@export var lights_selection : LightSelectionUI
@export var speed : float = 0.1

var animating = false

func _on_toggle_on():
	if animating:
		_is_toggled = false
		return

	lights_selection.on_context_shrunk()
	hide_nodes()

func _on_toggle_off():
	if animating:
		_is_toggled = true
		return
	
	show_nodes()

func hide_nodes():
	animating = true
	
	var progress = 0
	while progress < 1:
		progress += speed
		await get_tree().create_timer(0.01).timeout
		
		for node_path in nodes_to_hide:
			var node = get_node(node_path) as Control
			node.modulate = Color(1,1,1, 1 - progress)
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.modulate = Color(1,1,1,0)
		node.visible = false
	
	animating = false

func show_nodes():
	animating = true
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.visible = true
	
	var progress = 0
	while progress < 1:
		progress += speed
		await get_tree().create_timer(0.01).timeout
		
		for node_path in nodes_to_hide:
			var node = get_node(node_path) as Control
			node.modulate = Color(1,1,1, progress)
	
	for node_path in nodes_to_hide:
		var node = get_node(node_path) as Control
		node.modulate = Color(1,1,1,1)
	
	animating = false
