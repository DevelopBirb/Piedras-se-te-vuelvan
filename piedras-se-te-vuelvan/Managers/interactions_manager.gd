extends Node3D

@onready var player: CharacterBody3D = $"../Player"

signal object_picked_up(Node3D)
signal object_released(Node3D)

func _on_player_interacted_with(something) -> void:
	if something.is_in_group("interactable"):
		if something.is_in_group("object"):
			if player.held_object != null:
				object_released.emit(player.held_object)
				print_debug("released")
			object_picked_up.emit(something)
	else: if player.held_object != null:
		object_released.emit(player.held_object)
		
