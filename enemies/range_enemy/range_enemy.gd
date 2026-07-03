class_name RangeEnemy
extends Enemy

@export var audio_stream_player_2d: AudioStreamPlayer2D
@export var proyectile_launcher: ProyectileLauncher

func attack() -> void:
	animated_sprite_2d.play("shoot")
	audio_stream_player_2d.play()
	await get_tree().create_timer(0.6).timeout
	proyectile_launcher.spawn_and_launch(
			Player.active_player.hurtbox_component.global_position
	)
