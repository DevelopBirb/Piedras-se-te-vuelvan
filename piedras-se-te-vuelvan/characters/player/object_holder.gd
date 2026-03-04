extends Node3D
@onready var detector_ray_cast_3d: RayCast3D = $"../Interactor/DetectorRayCast3D"
@onready var player: CharacterBody3D = $"../.."

@export var minimum_verticality = 0.5
@export var release_height = 0.1
@export var object_rotate_sensitivity_z = 1

func _process(_delta: float) -> void:
	if player.held_object != null:
		hold_object()
	if Input.is_action_pressed("right_click") && player.held_object != null:
		rotate_object_z_axis_with_direction_buttons()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.is_action_pressed("right_click") && player.held_object != null:
		rotate_object_x_y_axis_with_mouse(event)

func pick_up_object(object : Node3D):
	player.held_object = object
	print_debug(object.name)

func release_object_if_surface_flat(object : Node3D):
	if target_is_object() || surface_vertical_enough():
		object.reparent(get_tree().current_scene)
		object.freeze = false
		place_released_object(object)
		player.held_object = null
		print_debug(object.name)
	else: return

func place_released_object(object):
	var surface_point = detector_ray_cast_3d.get_collision_point()
	object.position = surface_point + Vector3.UP * release_height

func hold_object():
		player.held_object.global_position = global_position
		player.held_object.freeze = true

func rotate_object_z_axis_with_direction_buttons():
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	player.held_object.rotation_degrees.z -= input_dir.x * object_rotate_sensitivity_z

func rotate_object_x_y_axis_with_mouse(event):
	player.held_object.rotation_degrees.y -= event.relative.x * player.mouse_sensitivity_h
	player.held_object.rotation_degrees.x -= event.relative.y * player.mouse_sensitivity_v

func target_is_object():
	if detector_ray_cast_3d.get_collider().is_in_group("object"):
		return true

func surface_vertical_enough():
	if detector_ray_cast_3d.get_collision_normal().y > minimum_verticality:
		return true
