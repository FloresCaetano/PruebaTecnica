class_name RangeEnemy
extends Enemy

@export var proyectile_launcher: ProyectileLauncher

func attack() -> void:
	animated_sprite_2d.play("shoot")
	await get_tree().create_timer(0.6).timeout
	proyectile_launcher.spawn_and_launch(
			Player.active_player.hurtbox_component.global_position
	)
