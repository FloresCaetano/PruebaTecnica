extends Control

@export var heart_icon : PackedScene
@onready var hearts_container: HBoxContainer = $MarginContainer/HSplitContainer/HeartsContainer


func _ready() -> void:
	Player.active_player.health_component.damage_taken.connect(_on_player_health_component_damage_taken)
	update_heart_count()

func _on_player_health_component_damage_taken(_amount : float) -> void:
	call_deferred("update_heart_count")
	


func update_heart_count() -> void:
	for heart in hearts_container.get_children():
		heart.free()
	
	for index in range(Player.active_player.health_component.current_health):
		hearts_container.add_child(heart_icon.instantiate())
	
