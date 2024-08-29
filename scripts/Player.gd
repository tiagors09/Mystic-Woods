extends KinematicBody2D

const PARTICLES = preload("res://scenes/RunParticles.tscn")
onready var animation_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
var velocity
var last_direction
var is_attacking
export(int) var speed = 60

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
}

var directions = {
	Vector2.ZERO: IDLE_FRONT,
	Vector2.UP: RUN_BACK,
	Vector2.DOWN: RUN_FRONT,
	Vector2.RIGHT: RUN_SIDE_RIGHT,
	Vector2.LEFT: RUN_SIDE_LEFT,
	Vector2(-1,-1): RUN_DIAGONAL_Q2,
	Vector2(1,-1): RUN_DIAGONAL_Q1,
	Vector2(-1,1): RUN_DIAGONAL_Q3,
	Vector2(1,1): RUN_DIAGONAL_Q4,
}
var animation = {
	IDLE_FRONT: {
		"name": "idle_front",
		"flip": false,
	},
	IDLE_SIDE_LEFT: {
		"name": "idle_side",
		"flip": true,
	}, 
	IDLE_SIDE_RIGHT: {
		"name": "idle_side",
		"flip": false,
	},
	IDLE_BACK: {
		"name": "idle_back",
		"flip": false,
	},
	RUN_FRONT: {
		"name": "run_front",
		"flip": false,
	},
	RUN_SIDE_LEFT: {
		"name": "run_side",
		"flip": true,
	}, 
	RUN_SIDE_RIGHT: {
		"name": "run_side",
		"flip": false,
	}, 
	RUN_BACK: {
		"name": "run_back",
		"flip": false,
	},  
	RUN_DIAGONAL_Q1: {
		"name": "run_back",
		"flip": false,
	}, 
	RUN_DIAGONAL_Q2: {
		"name": "run_back",
		"flip": false,
	}, 
	RUN_DIAGONAL_Q3: {
		"name": "run_front",
		"flip": false,
	},
	RUN_DIAGONAL_Q4: {
		"name": "run_front",
		"flip": false,
	},
	ATTACK_FRONT: {
		"name": "attack_front",
		"flip": false,
	}, 
	ATTACK_SIDE_LEFT: {
		"name": "attack_side",
		"flip": true,
	}, 
	ATTACK_SIDE_RIGHT: {
		"name": "attack_side",
		"flip": false,
	},
	ATTACK_BACK: {
		"name": "attack_back",
		"flip": false,
	},
}

func _physics_process(_delta):
	_move()
	Global.player_position = position

func intance_particle():
	var particle = PARTICLES.instance()
	get_tree().root.add_child(particle)
	particle.global_position = global_position + Vector2(0,16)
	particle.z_index = 1
	particle.play_particles()

func _update_animation(direction):
	if(direction != Vector2.ZERO and last_direction != direction):
		last_direction = direction
	
	animation_player.play(animation[directions[direction]]["name"])
	sprite.set_flip_h(animation[directions[direction]]["flip"])

func _move():
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	_update_animation(direction.snapped(Vector2.ONE))

	velocity = direction * speed

	velocity = move_and_slide(velocity, Vector2.ZERO)

