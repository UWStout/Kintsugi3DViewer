extends OptionButton

@export var graphics_controller : GraphicsController

func _ready():
	select(graphics_controller.ssao)

func _on_item_selected(index):
	graphics_controller.change_ssao(index)
