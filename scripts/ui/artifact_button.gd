extends Button

var data: ArtifactData

func _pressed():
	print("Artifact button '%s' pressed!" % data.name)
	#TODO: Load the object using urls found in the data dictionary

func setup(artifact_data: ArtifactData):
	data = artifact_data
	text = data.name
	var placeholder = icon.get_image()
	icon = HTTPImageTexture.new()
	icon.set_image(placeholder)
	icon.set_url(data.iconUrl)
	icon.load(self)
