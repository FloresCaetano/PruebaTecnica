extends Node

func trigger_hit_stop(duration: float, time_scale: float, recover_time : float = 0.2) -> void:
	Engine.time_scale = time_scale
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	if recover_time <= 0:
		Engine.time_scale = 1.0
		return
	
	var tween = Engine.get_main_loop().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(Engine, "time_scale", 1.0, recover_time)
