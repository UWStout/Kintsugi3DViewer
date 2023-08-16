# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

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
