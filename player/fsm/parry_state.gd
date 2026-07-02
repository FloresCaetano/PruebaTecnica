extends LimboState

@export var parry_state_duration : float = 0.9
var player: Player

func _enter() -> void:
	player = agent as Player
	
	player.animated_sprite.play("parry")
	get_tree().create_timer(parry_state_duration).timeout.connect(_on_parry_state_timer_end)
	
	player.health_component.damage_taken.connect(_on_damage_taken)
	
	player.parry_cooldown_timer.start()


func _update(delta: float) -> void:
	player.apply_friction(delta)
	player.update_input()


func _exit() -> void:
	player.health_component.damage_taken.disconnect(_on_damage_taken)


func _on_parry_state_timer_end() -> void:
	dispatch(&"parry_stopped")


func _on_damage_taken(_amount) -> void:
	TimeManager.trigger_hit_stop(0.2, 0.05, 0.1)
