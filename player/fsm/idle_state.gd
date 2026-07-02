extends LimboState

var player: Player


func _enter() -> void:
	player = agent as Player
	player.animated_sprite.play("idle")


func _update(delta: float) -> void:
	player.update_input()
	player.apply_friction(delta)
	player.handle_flipping()
	
	# Transition Conditions:
	if player.input_direction != Vector2.ZERO:
		dispatch(&"movement_started")
		return
	
	if player.current_buffered_action == player.BufferedAction.ATTACK:
		dispatch(&"attack_started")
		return
	
	if player.current_buffered_action == player.BufferedAction.PARRY:
		if player.parry_cooldown_timer.is_stopped():
			dispatch(&"parry_started")
		return
