extends Node3D

func _on_artifact_bounds_changed(aabb : AABB):
	var horizScale = max(aabb.size.x, aabb.size.z)
	self.scale.x = horizScale
	self.scale.z = horizScale
