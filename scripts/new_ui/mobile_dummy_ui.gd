extends Control

func _ready():
	if not (OS.get_name() == "Android" or OS.get_name() == "iOS"):
		hide()
	else:
		show()
