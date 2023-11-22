extends Node2D

@onready var anim_player = $AnimationPlayer
const grass_overlay_texture = preload("res://Assets/Grass/stepped_tall_grass.png")
var grass_overlay: TextureRect = null

var player_inside: bool = false

# Player exiting grass
func _on_player_player_moving_signal():
	player_inside = false

# Player in grass
func _on_player_player_stopped_signal():
	pass

func _on_area_2d_body_entered(body):
	anim_player.play("Stepped")
