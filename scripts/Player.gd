extends KinematicBody2D

const PARTICLES = preload("res://scenes/RunParticles.tscn")

onready var animation_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var hurtbox_collision = get_node("HurtBox/CollisionShape2D")
onready var timer = get_node("Timer")

export(int) var speed = 60

var velocity = 0
var life = 3
var is_running = false
var is_attacking = false
var current_state = ANIMATIONS[IDLE_FRONT]
var last_direction

enum {
	IDLE_FRONT,
	IDLE_SIDE_LEFT,
	IDLE_SIDE_RIGHT,
	IDLE_BACK,
	RUN_FRONT,
	RUN_SIDE_LEFT,
	RUN_SIDE_RIGHT,
	RUN_BACK,
	RUN_DIAGONAL_Q1,
	RUN_DIAGONAL_Q2,
	RUN_DIAGONAL_Q3,
	RUN_DIAGONAL_Q4,
	ATTACK_FRONT,
	ATTACK_SIDE_LEFT,
	ATTACK_SIDE_RIGHT,
	ATTACK_BACK,
	DIE
}

const ANIMATIONS = {
	IDLE_FRONT: {
		"anim_name": "idle_front",
		"flip": false,
	},
	IDLE_SIDE_LEFT: {
		"anim_name": "idle_side",
		"flip": true,
	},
	IDLE_SIDE_RIGHT: {
		"anim_name": "idle_side",
		"flip": false,
	},
	IDLE_BACK: {
		"anim_name": "idle_back",
		"flip": false,
	},
	RUN_FRONT: {
		"anim_name": "run_front",
		"flip": false,
	},
	RUN_SIDE_LEFT: {
		"anim_name": "run_side",
		"flip": true,
	},
	RUN_SIDE_RIGHT: {
		"anim_name": "run_side",
		"flip": false,
	},
	RUN_BACK: {
		"anim_name": "run_back",
		"flip": false,
	},
	RUN_DIAGONAL_Q1: {
		"anim_name": "run_back",
		"flip": false,
	},
	RUN_DIAGONAL_Q2: {
		"anim_name": "run_back",
		"flip": false,
	},
	RUN_DIAGONAL_Q3: {
		"anim_name": "run_front",
		"flip": false,
	},
	RUN_DIAGONAL_Q4: {
		"anim_name": "run_front",
		"flip": false,
	},
	ATTACK_FRONT: {
		"anim_name": "attack_front",
		"flip": false,
	},
	ATTACK_SIDE_LEFT: {
		"anim_name": "attack_side",
		"flip": true,
	},
	ATTACK_SIDE_RIGHT: {
		"anim_name": "attack_side",
		"flip": false,
	},
	ATTACK_BACK: {
		"anim_name": "attack_back",
		"flip": false,
	},
	DIE: {
		"anim_name": "die",
		"flip": false,
	}
}

const DIRECTIONS = {
	Vector2.ZERO: {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[ATTACK_FRONT],
		"q3": ANIMATIONS[DIE],
	},
	Vector2.LEFT: {
		"q0": ANIMATIONS[IDLE_SIDE_LEFT],
		"q1": ANIMATIONS[RUN_SIDE_LEFT],
		"q2": ANIMATIONS[ATTACK_SIDE_LEFT],
		"q3": ANIMATIONS[DIE],
	},
	Vector2.RIGHT: {
		"q0": ANIMATIONS[IDLE_SIDE_RIGHT],
		"q1": ANIMATIONS[RUN_SIDE_RIGHT],
		"q2": ANIMATIONS[ATTACK_SIDE_RIGHT],
		"q3": ANIMATIONS[DIE],
	},
	Vector2.UP: {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_BACK],
		"q2": ANIMATIONS[ATTACK_BACK],
		"q3": ANIMATIONS[DIE],
	},
	Vector2.DOWN: {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[ATTACK_FRONT],
		"q3": ANIMATIONS[DIE],
	},
	Vector2(1, -1): {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_DIAGONAL_Q1],
		"q2": ANIMATIONS[ATTACK_BACK],
		"q3": ANIMATIONS[DIE],
	},
	Vector2(-1, -1): {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_DIAGONAL_Q2],
		"q2": ANIMATIONS[ATTACK_BACK],
		"q3": ANIMATIONS[DIE],
	},
	Vector2(-1, 1): {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_DIAGONAL_Q3],
		"q2": ANIMATIONS[ATTACK_FRONT],
		"q3": ANIMATIONS[DIE],
	},
	Vector2(1, 1): {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_DIAGONAL_Q4],
		"q2": ANIMATIONS[ATTACK_FRONT],
		"q3": ANIMATIONS[DIE],
	}
}

func _ready():
	last_direction = Vector2.ZERO
	_update_animation(Vector2.ZERO)

func _physics_process(_delta):
	_move()
	Global.player_position = position

func intance_particle():
	var particle = PARTICLES.instance()
	get_tree().root.add_child(particle)
	particle.global_position = global_position + Vector2(0, 16)
	particle.z_index = -1
	particle.play_particles()

func _update_animation(direction):
	is_running = direction != Vector2.ZERO

	if is_running and last_direction != direction:
		last_direction = direction
	
	if is_running and not is_attacking:
		current_state = DIRECTIONS[direction]['q1']
	elif is_attacking and not is_running:
		current_state = DIRECTIONS[last_direction]['q2']
	elif not is_attacking and not is_running:
		current_state = DIRECTIONS[last_direction]['q0']
	elif not is_running and not is_attacking and life <= 0:
		current_state = DIRECTIONS[direction]['q3']
	
	animation_player.play(current_state["anim_name"])
	sprite.set_flip_h(current_state["flip"])

func _move():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
	if life <= 0:
		is_attacking = false
		is_running = false
	
	if Input.is_action_just_pressed("attack"):
		is_attacking = true

	_update_animation(direction.snapped(Vector2.ONE))

	velocity = direction * speed

	velocity = move_and_slide(velocity, Vector2.ZERO)

func kill():
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("attack_"):
		is_attacking = false

func _on_HurtBox_area_entered(_area):
	pass

func _on_Sword_area_entered(_area):
	pass
