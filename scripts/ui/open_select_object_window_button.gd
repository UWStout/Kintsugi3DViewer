extends Button

@export var select_window : Window


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().gui_embed_subwindows = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if not select_window == null:
		select_window.popup_centered()
