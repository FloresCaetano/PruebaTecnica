extends Node

var menu_appearance_delay : float = 2.5

func restart_game():
	Player.active_player.animated_sprite.material.set_shader_parameter("radius", -0.3)
	get_tree().reload_current_scene()

func game_over() -> void:
	var enemies_container : Node2D = get_tree().get_first_node_in_group("enemies_container")
	var music_stream_player : AudioStreamPlayer = get_tree().get_first_node_in_group("music_stream_player")
	
	enemies_container.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	music_stream_player.stop()
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(Player.active_player.active_camera, "zoom", Vector2(3, 3), 0.4)
	await get_tree().create_timer(menu_appearance_delay).timeout
	MainMenu.active_menu.open_menu()

func close_game():
	get_tree().quit(0)
