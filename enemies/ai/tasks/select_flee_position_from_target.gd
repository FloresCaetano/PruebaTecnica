@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var flee_min_distance: float = 100.0
@export var flee_max_distance: float = 300.0
@export var position_var: StringName = &"pos"


func _generate_name() -> String:
	return "SelectFleePosFrom %s -> %s" % [
		LimboUtility.decorate_var(target_var),
		LimboUtility.decorate_var(position_var)
	]


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target) or not is_instance_valid(agent):
		return FAILURE

	var base_direction : Vector2 = target.global_position.direction_to(agent.global_position)
	if base_direction == Vector2.ZERO:
		base_direction = Vector2.RIGHT
		
	var navigation_map: RID = agent.navigation_agent_2d.get_navigation_map()
	var best_position : Vector2 = agent.global_position
	var max_found_distance: float = -1.0
	
	# Evaluate directions in alternating fan pattern (0°, +20°, -20°, +40°, -40°...)
	for i in range(18):
		var angle_offset: float = deg_to_rad(20.0 * float(i))
		if i % 2 == 1:
			angle_offset = -angle_offset
			
		var test_direction := base_direction.rotated(angle_offset)
		var target_vector : Vector2 = agent.global_position + (test_direction * flee_max_distance)
		var test_flee_position := NavigationServer2D.map_get_closest_point(navigation_map, target_vector)
		var distance_from_target := target.global_position.distance_to(test_flee_position)
		
		if distance_from_target > max_found_distance:
			max_found_distance = distance_from_target
			best_position = test_flee_position
			
		if distance_from_target >= flee_min_distance:
			blackboard.set_var(position_var, test_flee_position)
			
			return SUCCESS
			
	# Fallback if no direction satisfies the minimum threshold
	blackboard.set_var(position_var, best_position)
	return SUCCESS
