extends Node

var FILE_PATH = "res://assets/index 1.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var json = JSON.new()
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var json_text = JSON.stringify(file.get_as_text(), "\t")
	file.close()

	var error = json.parse(json_text)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received)
		else:
			print("Unexpected Data")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
