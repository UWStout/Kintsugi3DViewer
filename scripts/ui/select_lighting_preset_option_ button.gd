extends OptionButton

class_name SelectLightingButton

var connected_controller : LightingController

# make the default preset active. Called in the connected_controller
func init():
	select(0)
	_on_item_selected(0)

func _on_item_selected(index : int):
	connected_controller.make_active(index)
	pass
