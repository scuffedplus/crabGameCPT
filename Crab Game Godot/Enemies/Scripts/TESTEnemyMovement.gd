extends AnimatedSprite2D
var i = 0
const walkdist = 250
var dir = 1
var enemNum = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i = i+1

	if i <= walkdist:
		position.x = position.x + dir
	else:
		i = 0
		dir = dir * -1


func _on_enemy_hitbox_tree_exited():
	queue_free()
