extends CharacterBody3D

signal interacted_with(Node3D)
signal looking_at(Node3D)

@export var player_locked := false

@onready var object_holder: Node3D = $Camera3D/ObjectHolder
@onready var holder_position = object_holder.position
@export var held_object : Node3D = null

@onready var character_mover: Node3D = $CharacterMover
@onready var interactor: Node3D = $Camera3D/Interactor

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_position = camera_3d.position
@onready var camera_rotation = camera_3d.rotation

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

var target : Node3D = null

@export var in_ossuary := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !player_locked && !in_ossuary:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		camera_3d.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 90)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		interact_with(target)
	
	if Input.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player_locked = true
	else:
		player_locked = false
		if in_ossuary:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if Input.is_action_just_pressed("free_lock_mouse"):
		var mouse_is_locked = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		if mouse_is_locked:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if  player_locked || in_ossuary:
		move_dir = Vector3.ZERO
	
	character_mover.set_move_dir(move_dir)
	if Input.is_action_just_pressed("jump") && !player_locked && !in_ossuary:
		character_mover.jump()
	
	if in_ossuary:
		point_interactor_to_mouse()


func interact_with(something):
	if something != null:
		if something.is_in_group("object") && (!something.get_parent().is_in_group("ossuary") || in_ossuary):
			var object = something
			if held_object != null:
				object_holder.release_object_if_surface_flat(held_object)
			object_holder.pick_up_object(object)
		if something.is_in_group("ossuary") || (something.get_parent().is_in_group("ossuary") && !in_ossuary):
			var ossuary = something
			if something.get_parent().is_in_group("ossuary") && !in_ossuary:
				ossuary = something.get_parent()
			if !in_ossuary:
				enter_ossuary(ossuary)
			else:
				if held_object != null:
					object_holder.release_object_if_surface_flat(held_object)
				else:
					exit_ossuary()
		if !something.is_in_group("interactable") && held_object != null && !in_ossuary:
			object_holder.release_object_if_surface_flat(held_object)
		else: if !something.is_in_group("interactable") && in_ossuary:
			exit_ossuary()

func enter_ossuary(ossuary : Node3D):
	player_locked = true
	in_ossuary = true
	camera_position = camera_3d.position
	camera_rotation = camera_3d.rotation
	camera_3d.global_position = ossuary.get_node("Camera3D").global_position
	camera_3d.global_rotation = ossuary.get_node("Camera3D").global_rotation
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func point_interactor_to_mouse():
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_start := camera_3d.project_ray_origin(mouse_pos)
	var direction := camera_3d.project_ray_normal(mouse_pos)
	interactor.look_at(ray_start + direction)

func exit_ossuary():
	interactor.rotation = Vector3.ZERO
	player_locked = false
	in_ossuary = false
	camera_3d.position = camera_position
	camera_3d.rotation = camera_rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_interactor_detector_looking_at(object: Node3D) -> void:
	target = object
	looking_at.emit(object)
