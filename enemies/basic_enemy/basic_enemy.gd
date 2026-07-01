extends CharacterBody2D

@export var acceleration: float = 20.0
@export var attack_duration : float = 0.7
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var hitbox_component: HitboxComponent = $Components/HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $Components/HurtboxComponent


func move(direction : Vector2) -> void:
	velocity = velocity.move_toward(direction, acceleration)
	move_and_slide()

func update_facing() -> void:
	if velocity.x != 0:
		face_dir(velocity.x)

func face_dir(dir : float) -> void:
	animated_sprite_2d.flip_h = dir < 0
	hitbox_component.scale.x = signf(dir)

func attack() -> void:
	hitbox_component.activate()
	animated_sprite_2d.play("attack")
	await get_tree().create_timer(attack_duration).timeout
	hitbox_component.desactivate()
