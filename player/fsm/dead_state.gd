extends LimboState

var player: Player

func _enter() -> void:
	player = agent as Player
	player.velocity = Vector2.ZERO
	
	if player.hitbox_component:
		player.hitbox_component.desactivate()
