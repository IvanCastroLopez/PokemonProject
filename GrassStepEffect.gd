extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	frame = 0
	play()


func _on_animation_finished():
	print("grass")
	queue_free()
