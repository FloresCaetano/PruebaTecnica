class_name BasicEnemy
extends Enemy

@export var audio_stream_player_2d: AudioStreamPlayer2D
@export var hitbox_component: HitboxComponent

func attack() -> void:
	if hitbox_component and animated_sprite_2d:
		hitbox_component.activate()
		animated_sprite_2d.play("attack")
		audio_stream_player_2d.play()
		await get_tree().create_timer(attack_duration).timeout
		hitbox_component.deactivate()


func is_good_position(p_position: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p_position
	params.collision_mask = 1 # Obstacle layer has value 1
	var collision := space_state.intersect_point(params)
	return collision.is_empty()
