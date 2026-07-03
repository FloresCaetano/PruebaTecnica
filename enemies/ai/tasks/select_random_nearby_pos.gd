@tool
extends BTAction
## Selects a random position nearby within the specified range and stores it on the blackboard. [br]
## Returns [code]SUCCESS[/code].

## Minimum distance to the desired position.
@export var range_min: float = 300.0

## Maximum distance to the desired position.
@export var range_max: float = 500.0

## Blackboard variable that will be used to store the desired position.
@export var position_var: StringName = &"pos"


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SelectRandomNearbyPos  range: [%s, %s]  ➜%s" % [
		range_min, range_max,
		LimboUtility.decorate_var(position_var)]


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	# 1. Generamos una dirección completamente aleatoria
	var random_direction := Vector2.RIGHT.rotated(randf_range(0.0, PI*2))
	var radius : float = randf_range(range_min, range_max)
	var random_distance := randf_range(radius * 0.5, radius)
	var target_vector : Vector2 = agent.global_position + (random_direction * random_distance)
	
	var navigation_map : RID = agent.get_world_2d().get_navigation_map()
	
	# 4. Forzamos a que el punto caiga dentro del polígono navegable más cercano
	var safe_target_position := NavigationServer2D.map_get_closest_point(navigation_map, target_vector)
	blackboard.set_var(position_var, safe_target_position)
	return SUCCESS
