@icon("res://components/health/health_component_icon.svg")
class_name HealthComponent
extends Node

signal max_health_changed(max_health: int)
signal damage_taken(amount : int)
signal died

@export var _max_health: int = 3 : set = set_max_health
@onready var _current_health: int = _max_health : set = set_current_health

func set_max_health(value: int) -> void:
	_max_health = max(1, value)
	max_health_changed.emit(_max_health)
	if _current_health > _max_health:
		_current_health = _max_health

func set_current_health(value: int) -> void:
	_current_health = clampi(value, 0, _max_health)
	if _current_health == 0:
		died.emit()

func damage(amount: int) -> void:
	set_current_health(_current_health - amount)
	damage_taken.emit(amount)

func heal(amount: int) -> void:
	set_current_health(_current_health + amount)
