extends Node3D

@onready var detector_ray_cast_3d: RayCast3D = $DetectorRayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var object_holder: Node3D = $"../ObjectHolder"

func _process(delta: float) -> void:
	if !player.player_locked:
		if detector_ray_cast_3d.is_colliding():
			var target = detector_ray_cast_3d.get_collider()
			player.looking_at.emit(target)
			if Input.is_action_just_pressed("interact"):
				player.interacted_with.emit(target)
	else:
		pass
