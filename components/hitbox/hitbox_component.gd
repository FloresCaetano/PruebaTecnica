@icon("res://components/hitbox/hitbox_component_icon.svg")
class_name HitboxComponent
extends Area2D

@export var damage: int = 1

func _init() -> void:
	# We've disabled monitoring by default, animations will turn it on or off
	monitoring = false 
	monitorable = true
