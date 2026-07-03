extends LimboState

@export var hurt_sound : AudioStream

var player: Player

func _enter() -> void:
	player = agent as Player
	
	if player.health_component.current_health == 0:
		dispatch(&"died")
		return
	
	player.audio_stream_player_2d.stream = hurt_sound
	player.audio_stream_player_2d.play()
	player.play_damage_flash()
	player.play_camera_shake()
	TimeManager.trigger_hit_stop(0.05, 0.01, 0.0)


func _update(delta: float) -> void:
	player.apply_friction(delta)
	player.update_input()
	dispatch(&"recovered")
