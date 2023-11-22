extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
const grass_overlay_texture: Texture = preload("res://Assets/Grass/stepped_tall_grass.png")
var grass_overlay: TextureRect = null

var player_inside: bool = false

func _ready():
	# Find the Player node in the common ancestor (Town Scene)
	var player_node = %Player
	
	# Connect to signals emitted by the Player node
	if player_node:
		player_node.player_moving_signal.connect("_player_exiting_grass")
		player_node.player_stopped_signal.connect("_player_entered_grass")

func _player_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
	
func _player_entered_grass():
	if player_inside:
		grass_overlay = TextureRect.new()
		grass_overlay.texture = grass_overlay_texture
		grass_overlay.rect_position = position
		get_tree().current_scene.add_child(grass_overlay)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):  # Check if the entering body is the Player
		player_inside = true
		anim_player.play("Stepped")
