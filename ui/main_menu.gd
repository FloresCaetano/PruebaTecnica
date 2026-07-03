class_name MainMenu
extends Control

static var active_menu : MainMenu
@export var menu_animation_duration : float = 0.5
var is_open : bool = false

func _ready() -> void:
	active_menu = self
	close_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_menu"):
		if is_open:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	is_open = true
	visible = true
	modulate = Color.TRANSPARENT
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, menu_animation_duration)

func close_menu() -> void:
	is_open = false
	visible = false
	modulate = Color.WHITE
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, menu_animation_duration)


func _on_btn_restart_pressed() -> void:
	GameManager.restart_game()


func _on_btn_close_game_pressed() -> void:
	GameManager.close_game()
