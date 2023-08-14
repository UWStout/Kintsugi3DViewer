extends Node

var parameters : Dictionary

func _ready():
	populate_parameters()

func populate_parameters():
	# If the program is not run through the web, then there is no URL to read
	if not OS.get_name() == "Web":
		return
	
	var query_string : String = JavaScriptBridge.eval("window.location.search").trim_prefix("?")
	
	# Find every parameter in the URL and add it to the dictionary
	var params = query_string.split("&")
	for param in params:
		var split_param = param.split("=")
		if split_param.size() == 2:
			var key = split_param[0]
			var value = split_param[1]
			
			if not parameters.has(key):
				parameters[key] = value
