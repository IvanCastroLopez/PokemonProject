extends CharacterBody2D

signal player_moving_signal
signal player_steppedd_signal

@export var walk_speed = 4.0
const TILE_SIZE = 16

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var ray = $RayCast2D

var direction_keys = []

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true
	initial_position = position
	
	
func _physics_process(delta):
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false

func process_player_input():
	
#	# Old movement
#	if input_direction.y == 0:
#		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
#	if input_direction.x == 0:
#		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	#New Movement
	# Get input direction from directional key input stack
	if direction_keys.back() == null:
		input_direction = Vector2.ZERO
	else:
		var key = direction_keys.back()
		if Input.is_action_pressed(key):
			if key == "ui_right":
				input_direction.x = 1
				input_direction.y = 0
			elif key == "ui_left":
				input_direction.x = -1
				input_direction.y = 0
			elif key == "ui_down":
				input_direction.x = 0
				input_direction.y = 1
			elif key == "ui_up":
				input_direction.x = 0
				input_direction.y = -1
			else:
				input_direction = Vector2.ZERO

	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
		
		initial_position = position
		is_moving = true
	else:
		anim_state.travel("Idle")
	
func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
		
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	player_state = PlayerState.IDLE

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.target_position = desired_step
	ray.force_raycast_update()
	if !ray.is_colliding():
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		is_moving = false
		
func _process(delta):
	# Store direction keys in a "stack", ordered by when they're pressed
	if Input.is_action_just_pressed("ui_right"):
		direction_keys.push_back("ui_right")
	elif Input.is_action_just_released("ui_right"):
		direction_keys.erase("ui_right")
	if Input.is_action_just_pressed("ui_left"):
		direction_keys.push_back("ui_left")
	elif Input.is_action_just_released("ui_left"):
		direction_keys.erase("ui_left")
	if Input.is_action_just_pressed("ui_down"):
		direction_keys.push_back("ui_down")
	elif Input.is_action_just_released("ui_down"):
		direction_keys.erase("ui_down")
	if Input.is_action_just_pressed("ui_up"):
		direction_keys.push_back("ui_up")
	elif Input.is_action_just_released("ui_up"):
		direction_keys.erase("ui_up")
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_up"):
		direction_keys.clear()
