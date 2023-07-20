class_name ExpandSiderbarButton extends Button

@export var sidebar_selection_menu : SidebarSelectionMenu

var _is_toggled : bool = false
var _is_animating : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if sidebar_selection_menu._expanding or sidebar_selection_menu._shrinking:
		return
	
	_is_toggled = not _is_toggled
	
	if _is_toggled:
		sidebar_selection_menu.expand_sidebar()
	else:
		sidebar_selection_menu.shrink_sidebar()
