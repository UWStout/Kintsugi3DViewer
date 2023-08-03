extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	select(graphics_controller.global_illumination)

func _on_item_selected(index):
	graphics_controller.change_global_illumination(index)
