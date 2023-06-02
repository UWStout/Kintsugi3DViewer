extends Button


func _pressed():
	print("Artifact button pressed!")

func setup(artifact_data: Dictionary):
	text = artifact_data.name
	var placeholder = icon.get_image()
	icon = HTTPImageTexture.new()
	icon.set_image(placeholder)
	icon.set_url(artifact_data.iconUrl)
	icon.load(self)
