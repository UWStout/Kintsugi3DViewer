extends SpotLight3D

func _on_environment_scale_changed(scale : float, old_scale : float):
	self.spot_range *= scale / old_scale
