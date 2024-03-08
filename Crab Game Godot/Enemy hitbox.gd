extends Area2D
var Health = 3

const Damage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Health <= 0):
		queue_free()

func TakeDamage(Damage):
	Health -= Damage
	
func GetDamage():
	return(Damage)
