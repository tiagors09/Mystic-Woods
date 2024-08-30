extends KinematicBody2D

onready var animated_sprite = get_node("AnimatedSprite")
onready var timer = get_node("Timer")
onready var slime = get_node(".")

enum { 
	WALKING_SPEED = 10, 
	RUN_SPEED = 25,
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
	ANIMATIONS[IDLE_FRONT], 
	ANIMATIONS[IDLE_BACK], 
	ANIMATIONS[IDLE_SIDE_LEFT], 
	ANIMATIONS[IDLE_SIDE_RIGHT], 
	ANIMATIONS[WALKING_FRONT], 
	ANIMATIONS[WALKING_BACK], 
	ANIMATIONS[WALKING_SIDE_RIGHT], 
	ANIMATIONS[WALKING_SIDE_LEFT]
]

var is_patrolling = true
var is_following_player = false
var is_taking_damage = false
var last_state = null
var speed = WALKING_SPEED
var velocity
var last_direction
var direction
var current_state

const WAIT_TIME = 5

var directions = {
	Vector2.ZERO: {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[TAKING_DAMAGE_FRONT],
		"q3": ANIMATIONS[WALKING_FRONT],
	},
	Vector2.UP: {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_BACK],
		"q2": ANIMATIONS[TAKING_DAMAGE_BACK],
		"q3": ANIMATIONS[WALKING_BACK],
	},
	Vector2.DOWN: {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[TAKING_DAMAGE_FRONT],
		"q3": ANIMATIONS[WALKING_FRONT],
	},
	Vector2.RIGHT: {
		"q0": ANIMATIONS[IDLE_SIDE_RIGHT],
		"q1": ANIMATIONS[RUN_SIDE_RIGHT],
		"q2": ANIMATIONS[TAKING_DAMAGE_SIDE_RIGHT],
		"q3": ANIMATIONS[WALKING_SIDE_RIGHT],
	},
	Vector2.LEFT: {
		"q0": ANIMATIONS[IDLE_SIDE_LEFT],
		"q1": ANIMATIONS[RUN_SIDE_LEFT],
		"q2": ANIMATIONS[TAKING_DAMAGE_SIDE_LEFT],
		"q3": ANIMATIONS[WALKING_SIDE_LEFT],
	},
	Vector2(-1,-1): {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_BACK],
		"q2": ANIMATIONS[TAKING_DAMAGE_BACK],
		"q3": ANIMATIONS[WALKING_BACK],
	},
	Vector2(1,-1): {
		"q0": ANIMATIONS[IDLE_BACK],
		"q1": ANIMATIONS[RUN_BACK],
		"q2": ANIMATIONS[TAKING_DAMAGE_BACK],
		"q3": ANIMATIONS[WALKING_BACK],
	},
	Vector2(-1,1): {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[TAKING_DAMAGE_FRONT],
		"q3": ANIMATIONS[WALKING_FRONT],
	},
	Vector2(1,1): {
		"q0": ANIMATIONS[IDLE_FRONT],
		"q1": ANIMATIONS[RUN_FRONT],
		"q2": ANIMATIONS[TAKING_DAMAGE_FRONT],
		"q3": ANIMATIONS[WALKING_FRONT],
	},
}

const ANIMATIONS = {
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
	TAKING_DAMAGE_FRONT: {
		"name": "taking_damage_front",
		"flip": false,
	}, 
	TAKING_DAMAGE_SIDE_LEFT: {
		"name": "taking_damage_side",
		"flip": true,
	}, 
	TAKING_DAMAGE_SIDE_RIGHT: {
		"name": "taking_damage_side",
		"flip": false,
	},
	TAKING_DAMAGE_BACK: {
		"name": "taking_damage_back",
		"flip": false,
	}, 
	WALKING_FRONT: {
		"name": "walking_front",
		"flip": false,
	}, 
	WALKING_SIDE_LEFT: {
		"name": "walking_side",
		"flip": true,
	},
	WALKING_SIDE_RIGHT: {
		"name": "walking_side",
		"flip": false,
	}, 
	WALKING_BACK: {
		"name": "walking_back",
		"flip": false,
	}, 
}

func _ready():
	randomize()
	var _seed = rand_seed(randi())
	_choose_patrol_pattern()
	_choose_direction()
	timer.autostart = true

func _choose_patrol_pattern():
	patrol_states.shuffle()
	current_state = patrol_states[randi() % len(patrol_states)]

func _choose_direction():
	direction = directions.keys()[randi() % len(directions.keys())]

func _move():
	if is_following_player and not is_patrolling:
		direction = position.direction_to(Global.player_position).snapped(Vector2.ONE)
		_update_animation()
	
	velocity = speed * direction
	velocity = move_and_slide(velocity,Vector2.ZERO)

func _update_animation():
	if direction != Vector2.ZERO and last_direction != direction:
		last_direction = direction
	
	if is_following_player and not is_patrolling:
		current_state = directions[direction]["q1"]
	elif not is_following_player and is_patrolling:
		_choose_patrol_pattern()
	elif not is_following_player and not is_patrolling:
		current_state = directions[direction]["q0"]
	elif is_taking_damage and not is_following_player and not is_patrolling:
		print('d')
		current_state = directions[direction]["q2"]
	
	animated_sprite.play(current_state["name"])
	animated_sprite.set_flip_h(current_state["flip"])
	
func _physics_process(_delta):
	_move()

func _on_PlayerDetector_body_entered(_body):
	timer.stop()
	speed = RUN_SPEED
	is_following_player = true
	is_patrolling = false
	_update_animation()

func _on_PlayerDetector_body_exited(_body):
	speed = WALKING_SPEED
	is_following_player = false
	is_patrolling = true
	timer.start(WAIT_TIME)
	
func _on_Timer_timeout():
	_choose_direction()
	_update_animation()

func _on_HurtBox_area_entered(area):
	position += direction * 20
