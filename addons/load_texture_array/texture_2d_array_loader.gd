extends Texture2DArray
class_name Texture2DArrayLoader

@export var imagesToLoad : Array[Image]

func _init():
	print("ran _init()")
	self.create_from_images(imagesToLoad)
	print(imagesToLoad.size())
