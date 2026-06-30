@icon("res://components/health/health_component_icon.svg")
class_name HealthComponent
extends Node

signal health_changed(current_health: int)
signal max_health_changed(max_health: int)
signal died

@export var max_health: int = 3 : set = set_max_health
@onready var current_health: int = max_health : set = set_current_health

func set_max_health(value: int) -> void:
	max_health = max(1, value)
	max_health_changed.emit(max_health)
	if current_health > max_health:
		current_health = max_health

func set_current_health(value: int) -> void:
	current_health = clampi(value, 0, max_health)
	health_changed.emit(current_health)
	if current_health == 0:
		died.emit()

func damage(amount: int) -> void:
	if amount <= 0: return
	set_current_health(current_health - amount)

func heal(amount: int) -> void:
	if amount <= 0: return
	set_current_health(current_health + amount)
