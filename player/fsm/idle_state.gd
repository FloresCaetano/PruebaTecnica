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
