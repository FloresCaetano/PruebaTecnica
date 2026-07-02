extends LimboState

var player: Player

func _enter() -> void:
	player = agent as Player
	
	if player.health_component._current_health == 0:
		dispatch(&"died")
		return
	
	player.play_damage_flash()
	TimeManager.trigger_hit_stop(0.05, 0.01, 0.0)


func _update(delta: float) -> void:
	player.apply_friction(delta)
	player.update_input()
	dispatch(&"recovered")
