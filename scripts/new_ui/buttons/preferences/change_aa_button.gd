extends OptionButton

@export var graphics_controller : GraphicsController

var state : int = 0

func _ready():
	select(graphics_controller.antialiasing)

func _on_item_selected(index):
	graphics_controller.change_antialiasing(index)
