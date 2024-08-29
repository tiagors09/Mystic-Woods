extends KinematicBody2D

onready var animated_sprite = get_node("AnimatedSprite")
onready var timer = get_node("Timer")
onready var slime = get_node(".")

enum { 
	WALKING_SPEED = 10, 
	RUN_SPEED = 15,
}

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
	TAKING_DAMAGE_FRONT, 
	TAKING_DAMAGE_SIDE_LEFT, 
	TAKING_DAMAGE_SIDE_RIGHT, 
	TAKING_DAMAGE_BACK, 
	WALKING_FRONT, 
	WALKING_SIDE_LEFT, 
	WALKING_SIDE_RIGHT, 
	WALKING_BACK 
}

var patrol_states = [
	IDLE_FRONT, 
	IDLE_BACK, 
	IDLE_SIDE_LEFT, 
	IDLE_SIDE_RIGHT, 
	WALKING_FRONT, 
	WALKING_BACK, 
	WALKING_SIDE_RIGHT, 
	WALKING_SIDE_LEFT
]

var follow_player
var last_state
var current_state
var speed
var velocity

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
		"direction": Vector2.ZERO,
	},
	IDLE_SIDE_LEFT: {
		"name": "idle_side",
		"flip": true,
		"direction": Vector2.ZERO,
	}, 
	IDLE_SIDE_RIGHT: {
		"name": "idle_side",
		"flip": false,
		"direction": Vector2.ZERO,
	},
	IDLE_BACK: {
		"name": "idle_back",
		"flip": false,
		"direction": Vector2.ZERO
	},
	RUN_FRONT: {
		"name": "run_front",
		"flip": false,
		"direction": Vector2.DOWN
	},
	RUN_SIDE_LEFT: {
		"name": "run_side",
		"flip": true,
		"direction": Vector2.LEFT
	}, 
	RUN_SIDE_RIGHT: {
		"name": "run_side",
		"flip": false,
		"direction": Vector2.RIGHT
	}, 
	RUN_BACK: {
		"name": "run_back",
		"flip": false,
		"direction": Vector2.UP
	},  
	RUN_DIAGONAL_Q1: {
		"name": "run_back",
		"flip": false,
		"direction": Vector2(1,-1)
	}, 
	RUN_DIAGONAL_Q2: {
		"name": "run_back",
		"flip": false,
		"direction": Vector2(-1,-1)
	}, 
	RUN_DIAGONAL_Q3: {
		"name": "run_front",
		"flip": false,
		"direction": Vector2(-1,1)
	},
	RUN_DIAGONAL_Q4: {
		"name": "run_front",
		"flip": false,
		"direction": Vector2(1,1)
	},
	TAKING_DAMAGE_FRONT: {
		"name": "taking_damage_front",
		"flip": false,
		"direction": Vector2.DOWN
	}, 
	TAKING_DAMAGE_SIDE_LEFT: {
		"name": "taking_damage_side",
		"flip": true,
		"direction": Vector2.LEFT
	}, 
	TAKING_DAMAGE_SIDE_RIGHT: {
		"name": "taking_damage_side",
		"flip": false,
		"direction": Vector2.RIGHT
	},
	TAKING_DAMAGE_BACK: {
		"name": "taking_damage_back",
		"flip": false,
		"direction": Vector2.UP
	}, 
	WALKING_FRONT: {
		"name": "walking_front",
		"flip": false,
		"direction": Vector2.DOWN
	}, 
	WALKING_SIDE_LEFT: {
		"name": "walking_side",
		"flip": true,
		"direction": Vector2.LEFT
	},
	WALKING_SIDE_RIGHT: {
		"name": "walking_side",
		"flip": false,
		"direction": Vector2.RIGHT
	}, 
	WALKING_BACK: {
		"name": "walking_back",
		"flip": false,
		"direction": Vector2.UP
	}, 
}

func _ready():
	randomize()
	rand_seed(randi())
	_choose_patrol_pattern()
	speed = WALKING_SPEED
	follow_player = false

func _physics_process(_delta):
	if follow_player:
		var direction = position.direction_to(Global.player_position).snapped(Vector2.ONE)
		current_state = directions[direction]

	animated_sprite.play(animation[current_state]["name"])
	animated_sprite.flip_h = animation[current_state]["flip"]
	velocity = animation[current_state]["direction"] * speed
	
	velocity = move_and_slide(velocity, Vector2.ZERO)

func _on_PlayerDetector_body_entered(_body):
	follow_player = true
	speed = RUN_SPEED
	timer.stop()

func _on_PlayerDetector_body_exited(_body):
	follow_player = false
	speed = WALKING_SPEED
	timer.start(5)

func _choose_patrol_pattern():
	last_state = current_state
	current_state = patrol_states[randi() % len(patrol_states)]

func _on_Timer_timeout():
	_choose_patrol_pattern()

