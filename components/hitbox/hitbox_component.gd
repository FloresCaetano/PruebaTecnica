@icon("res://components/hitbox/hitbox_component_icon.svg")
class_name HitboxComponent
extends Area2D

@export var damage: int = 1
@export var is_active : bool = true

func _ready() -> void:
	if not is_active:
		desactivate()

func activate() -> void:
	visible = true
	monitoring = true

func desactivate() -> void:
	visible = false
	monitoring = false

func _on_hurtbox_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.damage(damage)
