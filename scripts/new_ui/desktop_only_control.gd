extends Control

func _ready():
	if (OS.get_name() == "Android"
		or OS.get_name() == "iOS"
		or OS.get_name() == "Web"):
		hide()
