extends AnimatableBody2D
var i = 0
const ElevatorDelay = 300
var Speed = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i += 1
	if (i >= ElevatorDelay):
		Speed = -Speed
	
