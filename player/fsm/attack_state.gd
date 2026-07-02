class_name PlayerAttackState
extends LimboState

@export var attack_animation: String = ""
@export var attack_frame: int = 0

var player: Player


func _enter() -> void:
	player = agent as Player
	player.animated_sprite.play(attack_animation)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)
	player.animated_sprite.frame_changed.connect(_on_frame_changed)


func _update(delta: float) -> void:
	player.apply_friction(delta)
	player.update_input()


func _exit() -> void:
		player.hitbox_component.deactivate()
		if player.animated_sprite.frame_changed.is_connected(_on_frame_changed):
			player.animated_sprite.frame_changed.disconnect(_on_frame_changed)
		if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
			player.animated_sprite.animation_finished.disconnect(_on_animation_finished)


func _on_frame_changed() -> void:
	if player and player.animated_sprite.frame == attack_frame:
		player.hitbox_component.activate()


func _on_animation_finished() -> void:
	pass
