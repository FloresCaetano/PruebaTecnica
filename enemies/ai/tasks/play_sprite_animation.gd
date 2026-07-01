@tool
extends BTAction

@export var animation_name: String = "idle"


func _generate_name() -> String:
	return "Play sprite animation -> " + LimboUtility.decorate_var(animation_name)


func _tick(_delta: float) -> Status:
	if agent.animated_sprite_2d:
		agent.animated_sprite_2d.play(animation_name)
		return SUCCESS
	
	return FAILURE
