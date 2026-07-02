extends PlayerAttackState


func _on_animation_finished() -> void:
	if player.current_buffered_action == player.BufferedAction.ATTACK:
		dispatch(&"attack_started")
		return
	dispatch(&"attack_finished")
