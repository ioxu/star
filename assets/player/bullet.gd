extends RigidBody3D


func _on_timer_timeout() -> void:
	self.queue_free()


func _on_body_entered(body: Node) -> void:
	self.queue_free()
