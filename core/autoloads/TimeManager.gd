extends Node

signal hit_stop_finished

var _hit_stop_tween: Tween

func trigger_hit_stop(duration: float, time_scale: float, recover_time: float = 0.2) -> void:
	if _hit_stop_tween and _hit_stop_tween.is_valid():
		_hit_stop_tween.kill()
	
	Engine.time_scale = time_scale
	
	_hit_stop_tween = create_tween()
	_hit_stop_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_hit_stop_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_hit_stop_tween.set_ignore_time_scale(true)
	
	_hit_stop_tween.tween_interval(duration)
	
	_hit_stop_tween.tween_property(Engine, "time_scale", 1.0, recover_time)
	_hit_stop_tween.tween_callback(func() -> void:
			hit_stop_finished.emit()
			)
