extends CharacterBody3D

signal interacted_with(Node3D)
signal looking_at(Node3D)

@export var player_locked := false

@onready var object_holder: Node3D = $Camera3D/ObjectHolder
@onready var holder_position = object_holder.position
@export var held_object : Node3D = null

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_position = camera_3d.position
@onready var camera_rotation = camera_3d.rotation

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !Input.is_action_pressed("right_click") && !player_locked:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		camera_3d.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 90)


func _process(delta: float) -> void:
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


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && !Input.is_action_pressed("right_click"):
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func lock_player(lock : bool):
	axis_lock_linear_x = lock
	axis_lock_linear_y = lock
	axis_lock_linear_z = lock
	player_locked = lock

func _on_interactions_manager_object_picked_up(object) -> void:
	object_holder.pick_up_object(object)

func _on_interactions_manager_object_released(object) -> void:
	object_holder.release_object_if_surface_flat(object)


func _on_interactions_manager_entered_ossuary(ossuary: Node3D) -> void:
	lock_player(true)
	camera_3d.global_position = ossuary.get_node("Camera3D").global_position
	camera_3d.global_rotation = ossuary.get_node("Camera3D").global_rotation
	if held_object != null:
		held_object.global_position = ossuary.global_position

func _on_interactions_manager_exited_ossuary(ossuary: Node3D) -> void:
	lock_player(false)
	camera_3d.position = camera_position
	camera_3d.rotation = camera_rotation
