extends Button # Or TextureButton

func _has_point(point: Vector2) -> bool:
	# Calculate the center point of the button
	var center = size / 2.0
	# Calculate the radius (half of the width)
	var radius = size.x / 2.0
	
	return point.distance_to(center) < radius
