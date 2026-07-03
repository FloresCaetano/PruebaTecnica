extends LimboState

@export var die_sound : AudioStream

var player: Player

func _enter() -> void:
	player = agent as Player
	player.velocity = Vector2.ZERO
	if player.hitbox_component:
		player.hitbox_component.deactivate()
	play_die_animation()
		

func play_die_animation() -> void:
	player.audio_stream_player_2d.stream = die_sound
	player.audio_stream_player_2d.play()
	var sprite_material : ShaderMaterial = player.animated_sprite.material as ShaderMaterial
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_material, "shader_parameter/radius", 1.0, 3.0)
