extends LimboState

var player: Player

func _enter() -> void:
	player = agent as Player
	
	player.animated_sprite.play("attack1")
	player.animated_sprite.animation_finished.connect(func(): 
			dispatch(&"attack_finished")
			)
	
	if player.hitbox_component:
		player.hitbox_component.activate()


func _update(delta: float) -> void:
	player.apply_friction(delta)
	player.update_input()

func _exit() -> void:
	if player.hitbox_component:
		player.hitbox_component.desactivate()
