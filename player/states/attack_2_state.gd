extends PlayerAttackState


func _on_animation_finished() -> void:
	dispatch(&"attack_finished")
