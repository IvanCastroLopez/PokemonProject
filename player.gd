extends CharacterBody2D

signal player_moving_signal
signal player_stopped_signal

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


func _process(delta: float) -> void:
	direction_storage() # activates the function through _process

func direction_storage():
	var directions = ["ui_right", "ui_left", "ui_down", "ui_up"]
	
	for dir in directions:
		if Input.is_action_just_pressed(dir):
			direction_keys.push_back(dir)
		elif Input.is_action_just_released(dir):
			direction_keys.erase(dir)
			
	if direction_keys.size() == 0:
		direction_keys.clear()

func process_player_input():
	#New Movement
	var direction_map = {
		"ui_right": Vector2(1, 0),
		"ui_left": Vector2(-1, 0),
		"ui_down": Vector2(0, 1),
		"ui_up": Vector2(0, -1)
	}

	
	if direction_keys.size() > 0:
		var key = direction_keys.back()
		input_direction = direction_map.get(key, Vector2.ZERO)
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
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false
		percent_moved_to_next_tile = 0.0 # Reset when colliding
