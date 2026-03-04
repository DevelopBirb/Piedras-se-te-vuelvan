extends Node3D

@onready var detector_ray_cast_3d: RayCast3D = $DetectorRayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var object_holder: Node3D = $"../ObjectHolder"

signal detector_looking_at(object : Node3D)

func _process(_delta: float) -> void:
	if !player.player_locked:
		if detector_ray_cast_3d.is_colliding():
			var target = detector_ray_cast_3d.get_collider()
			detector_looking_at.emit(target)
		else:
			var no_target = null
			detector_looking_at.emit(no_target)
	else:
		pass
