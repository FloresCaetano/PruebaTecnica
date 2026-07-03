@icon("res://components/health/health_component_icon.svg")
class_name HealthComponent
extends Node

signal max_health_changed(max_health: int)
signal damage_taken(amount : int)
signal died

@export var _max_health: int = 3 : set = set_max_health
var is_dead : bool = false
var is_invulnerable : bool = false
@onready var current_health: int = _max_health : set = set_current_health

func set_max_health(value: int) -> void:
	_max_health = max(1, value)
	max_health_changed.emit(_max_health)
	if current_health > _max_health:
		current_health = _max_health

func set_current_health(value: int) -> void:
	current_health = clampi(value, 0, _max_health)
	if current_health == 0:
		is_dead = true
		died.emit()

func damage(amount: int) -> void:
	if is_dead:
		return
	damage_taken.emit(amount)
	if not is_invulnerable:
		set_current_health(current_health - amount)

func heal(amount: int) -> void:
	set_current_health(current_health + amount)
