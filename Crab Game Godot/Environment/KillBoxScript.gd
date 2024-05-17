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

	#Called by the C R A B to DEAL DAMAGE to THIS ENEMY
func TakeDamage(CrabStrength):
	Health -= CrabStrength
	
	#Called by the C R A B to see how much damage the C R A B should take
func GetDamage():
	return(Damage)
