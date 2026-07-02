@icon("res://components/proyectile_launcher/proyectile_launcher_icon.svg")
class_name ProyectileLauncher
extends Marker2D

@export var projectile_scene: PackedScene
@export var max_height: float = 150.0
@export var speed: float = 500.0

func spawn_and_launch(target_pos: Vector2) -> void:
	if not projectile_scene:
		return
		
	var projectile : Node2D = projectile_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(projectile)
	
	var start_pos : Vector2 = global_position
	projectile.global_position = start_pos
	
	var distance : float = start_pos.distance_to(target_pos)
	var dynamic_max_height: float = distance / 3.0
	var duration : float = distance / speed
	
	# Instantiate a typed context object for this specific shot instance.
	# This avoids data conflicts if there are multiple proyectiles.
	var context := TrajectoryContext.new()
	context.projectile = projectile
	context.start_pos = start_pos
	context.target_pos = target_pos
	context.previous_pos = start_pos
	context.max_height = dynamic_max_height
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	# Bind the typed context instance to the tracking method.
	tween.tween_method(
		_update_parabolic_trajectory.bind(context),
		0.0, 1.0, duration
	)
	
	# Clean callback trigger when the trajectory completes.
	tween.tween_callback(func() -> void:
			if is_instance_valid(context.projectile): # In case arrow gets destroyed mid-air
				_on_trajectory_finished(context.projectile)
			)


func _update_parabolic_trajectory(time: float, context: TrajectoryContext) -> void:
	if not is_instance_valid(context.projectile):
		return
		
	# Calculate the base linear interpolation.
	var base_pos : Vector2 = context.start_pos.lerp(context.target_pos, time)
	
	# Calculate the parabolic arc displacement.
	var current_height : float = 4.0 * context.max_height * time * (1.0 - time)
	var current_pos := Vector2(base_pos.x, base_pos.y - current_height)
	
	# Apply the newly calculated position and rotational angle.
	context.projectile.global_position = current_pos
	if current_pos != context.previous_pos:
		context.projectile.rotation = (current_pos - context.previous_pos).angle()
	
	# Update the tracking reference inside the typed class context.
	context.previous_pos = current_pos


func _on_trajectory_finished(projectile: Node2D) -> void:
	if is_instance_valid(projectile):
		on_projectile_trayectory_ends(projectile)


func on_projectile_trayectory_ends(projectile: Node2D) -> void:
	# TODO: Play arrow fail sound
	var tween : Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(projectile, "modulate", Color.TRANSPARENT, 0.2)
	
	tween.tween_callback(projectile.queue_free)


# =============================================================================
# Internal Data Container Class
# =============================================================================
class TrajectoryContext:
	var projectile: Node2D
	var start_pos: Vector2
	var target_pos: Vector2
	var previous_pos: Vector2
	var max_height: float
