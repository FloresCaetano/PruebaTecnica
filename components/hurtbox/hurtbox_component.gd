@icon("res://components/hurtbox/hurtbox_component_icon.svg")
class_name HurtboxComponent
extends Area2D

@export var damage: int = 1

func _init() -> void:
	# Desactivamos el monitoreo por defecto; las animaciones lo encenderán/apagarán
	monitoring = false 
	monitorable = true
