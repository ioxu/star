extends RigidBody3D


func _on_timer_timeout() -> void:
	self.queue_free()
