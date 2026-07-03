class_name Player
extends CharacterBody2D

enum BufferedAction {
	NONE,
	ATTACK,
	PARRY,
}

static var active_player : Player
@export var active_camera : Camera2D
@export var speed: float = 150.0
@export var acceleration: float = 20.0
var input_direction: Vector2 = Vector2.ZERO
var current_buffered_action: BufferedAction = BufferedAction.NONE

@onready var parry_particles: GPUParticles2D = $ParryParticles
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var footstep_sounds: AudioStreamPlayer2D = $FootstepSounds
@onready var parry_cooldown_timer: Timer = $ParryCooldownTimer
@onready var input_buffer_timer: Timer = $InputBufferTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shaker_component_2d: ShakerComponent2D = $Camera2D/ShakerComponent2D
# HSM
@onready var hsm: LimboHSM = $HSM
@onready var idle_state: LimboState = $HSM/IdleState
@onready var walk_state: LimboState = $HSM/WalkState
@onready var attack_state: LimboState = $HSM/AttackState
@onready var attack_1_state: LimboState = $HSM/AttackState/Attack1State
@onready var attack_2_state: LimboState = $HSM/AttackState/Attack2State
@onready var parry_state: LimboState = $HSM/ParryState
@onready var hurt_state: LimboState = $HSM/HurtState
@onready var dead_state: LimboState = $HSM/DeadState
# Components
@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var hurtbox_component: HurtboxComponent = $Components/HurtboxComponent
@onready var hitbox_component: HitboxComponent = $Components/HitboxComponent




func _ready() -> void:
	active_player = self
	_init_state_machine()


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _init_state_machine() -> void:
	hsm.add_transition(idle_state, walk_state, &"movement_started")
	hsm.add_transition(idle_state, attack_state, &"attack_started")
	hsm.add_transition(idle_state, hurt_state, &"damage_taken")
	hsm.add_transition(idle_state, parry_state, &"parry_started")
	
	hsm.add_transition(walk_state, idle_state, &"movement_stopped")
	hsm.add_transition(walk_state, attack_state, &"attack_started")
	hsm.add_transition(walk_state, hurt_state, &"damage_taken")
	hsm.add_transition(walk_state, parry_state, &"parry_started")
	
	hsm.add_transition(attack_state, idle_state, &"attack_finished")
	hsm.add_transition(attack_state, hurt_state, &"damage_taken")
	# --- COMBO INTERNAL LOGIC (SUB-HSM) ---
	attack_state.add_transition(attack_1_state, attack_2_state, &"attack_started")
	
	hsm.add_transition(parry_state, idle_state, &"parry_stopped")
	
	hsm.add_transition(hurt_state, idle_state, &"recovered")
	hsm.add_transition(hsm.ANYSTATE, dead_state, &"died")
	
	hsm.add_transition(dead_state, idle_state, &"level_restarted")
	
	hsm.initialize(self)
	hsm.set_active(true)


func update_input() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if Input.is_action_just_pressed("attack"):
		buffer_action(BufferedAction.ATTACK, 0.3)
	elif Input.is_action_just_pressed("parry"):
		buffer_action(BufferedAction.PARRY, 0.15)


func buffer_action(action: BufferedAction, duration: float) -> void:
	current_buffered_action = action
	input_buffer_timer.start(duration)


func clear_buffer() -> void:
	current_buffered_action = BufferedAction.NONE
	input_buffer_timer.stop()


func _on_input_buffer_timer_timeout() -> void:
	current_buffered_action = BufferedAction.NONE


func apply_movement(delta: float) -> void:
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration)
	else:
		apply_friction(delta)


func apply_friction(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration)


func handle_flipping() -> void:
	if input_direction.x > 0:
		animated_sprite.flip_h = false
		hitbox_component.scale.x = 1.0
	elif input_direction.x < 0:
		animated_sprite.flip_h = true
		hitbox_component.scale.x = -1.0


func play_damage_flash() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.set_speed_scale(1.0 / Engine.time_scale)
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)


func play_camera_shake() -> void:
	shaker_component_2d.play_shake()


func _on_health_component_damage_taken(_amount: int) -> void:
	hsm.dispatch(&"damage_taken")


func _on_health_component_died() -> void:
	hsm.dispatch(&"died")
	GameManager.game_over()
