extends Node3D

@onready var player: CharacterBody3D = $"../Player"

signal entered_ossuary(ossuary : Node3D)
signal exited_ossuary(ossuary : Node3D)

signal object_picked_up(object : Node3D)
signal object_released(object : Node3D)

enum States {WALKING, OSSUARY}
var state : States = States.WALKING
signal state_changed(old_state : States, new_state : States)

func change_state(new_state : States):
	var previous_state = state
	state = new_state
	state_changed.emit(previous_state,state)
	print_debug(state)

func _on_player_interacted_with(something) -> void:
	if something.is_in_group("interactable"):
		if something.is_in_group("object"):
			if player.held_object != null:
				object_released.emit(player.held_object)
				print_debug("released")
			object_picked_up.emit(something)
		if something.is_in_group("ossuary"):
			entered_ossuary.emit(something)
			change_state(States.OSSUARY)
	else: if player.held_object != null:
		object_released.emit(player.held_object)




func _on_state_changed(old_state: int, new_state: int) -> void:
	if new_state == States.OSSUARY:
		pass
