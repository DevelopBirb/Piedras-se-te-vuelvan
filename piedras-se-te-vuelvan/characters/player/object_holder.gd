extends Node3D
@onready var detector_ray_cast_3d: RayCast3D = $"../Interactor/DetectorRayCast3D"
@onready var player: CharacterBody3D = $"../.."

@export var minimum_verticality = 0.5
@export var release_height = 0.1

func pick_up_object(object : Node3D):
	object.get_parent().remove_child(object)
	add_child(object)
	object.position = Vector3.ZERO
	object.freeze = true
	player.held_object = object
	print_debug(object.name)

func release_object_if_surface_flat(object : Node3D):
	if target_is_object() || surface_vertical_enough():
		remove_child(object)
		get_tree().root.add_child(object)
		place_released_object(object)
		object.freeze = false
		player.held_object = null
		print_debug(object.name)
	else: return

func place_released_object(object):
	var surface_point = detector_ray_cast_3d.get_collision_point()
	object.position = surface_point + Vector3.UP * release_height
	

func target_is_object():
	if detector_ray_cast_3d.get_collider().is_in_group("object"):
		return true

func surface_vertical_enough():
	if detector_ray_cast_3d.get_collision_normal().y > minimum_verticality:
		return true
