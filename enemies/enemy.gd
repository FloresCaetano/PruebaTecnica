class_name Enemy
extends CharacterBody2D

@export var acceleration: float = 20.0
@export var attack_duration: float = 0.2

@export_category("Nodes")
@export var animated_sprite_2d: AnimatedSprite2D
@export var animation_player: AnimationPlayer
@export var bt_player: BTPlayer
@export var navigation_agent_2d: NavigationAgent2D
@export var hurt_sound_player: AudioStreamPlayer2D

@export_category("Components")
@export var components: Node2D
@export var health_component: HealthComponent
@export var hurtbox_component: HurtboxComponent

func _ready() -> void:
	if health_component:
		health_component.damage_taken.connect(_on_health_component_damage_taken)
		health_component.died.connect(_on_health_component_died)


func move(target_velocity: Vector2) -> void:
	velocity = velocity.move_toward(target_velocity, acceleration)
	move_and_slide()


func update_facing() -> void:
	if velocity.x != 0.0:
		face_dir(velocity.x)


func face_dir(dir: float) -> void:
	if animated_sprite_2d:
		animated_sprite_2d.flip_h = dir < 0.0
	
	if components:
		components.scale.x = signf(dir)
		


func trigger_texture_flash(recovery_time : float) -> void:
	if animated_sprite_2d:
		var shader_material : ShaderMaterial = animated_sprite_2d.material as ShaderMaterial
		if shader_material:
			var tween : Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			shader_material.set_shader_parameter("flash_modifier", 1.0)
			tween.tween_property(shader_material, "shader_parameter/flash_modifier", 0.0, recovery_time)


func attack() -> void:
	pass


func move_along_path(target_position: Vector2, speed : float) -> void:
	if not navigation_agent_2d:
		return
		
	navigation_agent_2d.target_position = target_position
	
	if not navigation_agent_2d.is_navigation_finished():
		var next_path_position : Vector2 = navigation_agent_2d.get_next_path_position()
		var new_direction : Vector2 = global_position.direction_to(next_path_position)
		
		var target_velocity : Vector2 = new_direction * speed
		move(target_velocity)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration)
		move_and_slide()


func _on_health_component_damage_taken(_amount: int) -> void:
	if hurt_sound_player:
		hurt_sound_player.play()
	trigger_texture_flash(0.12)
	TimeManager.trigger_hit_stop(0.05, 0.001, 0.0)


func _on_health_component_died() -> void:
	TimeManager.trigger_hit_stop(0.05, 0.001, 0.3)
	if bt_player:
		bt_player.active = false
	
	if animation_player:
		animation_player.play("die")
		await animation_player.animation_finished
	queue_free()
