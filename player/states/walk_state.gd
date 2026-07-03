extends LimboState

@export var walk_sound : AudioStream
var player: Player


func _enter() -> void:
	player = agent as Player
	player.animated_sprite.play("walk")


func _update(delta: float) -> void:
	if not player.footstep_sounds.playing:
		player.footstep_sounds.play()
	player.update_input()
	player.apply_movement(delta)
	player.handle_flipping()
	
	# Transition Conditions:
	if player.input_direction == Vector2.ZERO:
		dispatch(&"movement_stopped")
		return
		
	if player.current_buffered_action == player.BufferedAction.ATTACK:
		dispatch(&"attack_started")
		return
		
	elif player.current_buffered_action == player.BufferedAction.PARRY:
		if player.parry_cooldown_timer.is_stopped():
			dispatch(&"parry_started")
		return
