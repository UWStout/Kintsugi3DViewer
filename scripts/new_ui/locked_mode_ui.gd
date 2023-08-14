extends Control

func _ready():
	if UrlReader.parameters.has("locked"):
		if str_to_var(UrlReader.parameters["locked"]) == true:
			hide()
		else:
			show()
