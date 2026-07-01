@icon("res://components/hurtbox/hurtbox_component_icon.svg")
class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

func damage(amount: int) -> void:
	if health_component:
		health_component.damage(amount)
