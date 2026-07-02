extends Node2D


func _on_hitbox_component_hit_landed(_target: HurtboxComponent) -> void:
	queue_free()
