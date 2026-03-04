extends RigidBody3D
@onready var timer: Timer = $Timer
var object_to_freeze : Node3D = null



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("object"):
		timer.start()
		object_to_freeze = body
		print_debug("frozen")


func _on_timer_timeout() -> void:
	object_to_freeze.freeze = true
	object_to_freeze.reparent(self)
	timer.stop()
