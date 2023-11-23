extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
const grass_overlay_texture: Texture = preload("res://Assets/Grass/stepped_tall_grass.png")
const GrassStepEffect = preload("res://GrassStepEffect.tscn")
var grass_overlay: TextureRect = null

var player_inside: bool = false

var player_node

func _ready():
	# Find the Player node in the common ancestor
	player_node = get_node("../../YSort/Player")
	
	# Connect to signals emitted by the Player node
	if player_node:
		player_node.player_moving_signal.connect(_player_exiting_grass)
		player_node.player_stopped_signal.connect(_player_entered_grass)

# player_exiting_grass
func _player_exiting_grass():
	player_inside = false
	# Remove the grass overlay if it exists
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
	
	# player_in_grass
func _player_entered_grass():
	if player_inside:
		# Check if the grass overlay already exists
		if is_instance_valid(grass_overlay):
			grass_overlay.queue_free()
			
		var grass_step_effect = GrassStepEffect.instantiate()
		grass_step_effect.set_position(player_node.position)
		get_tree().current_scene.add_child(grass_step_effect)
		
		grass_overlay = TextureRect.new()
		grass_overlay.texture = grass_overlay_texture
		grass_overlay.set_position(player_node.position)
		get_tree().current_scene.add_child(grass_overlay)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):  # Check if the entering body is the Player
		player_inside = true
		anim_player.play("Stepped")
