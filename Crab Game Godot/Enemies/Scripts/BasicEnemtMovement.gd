extends CharacterBody2D

@onready var _Animator = $Sprite2D/AnimationPlayer

var Fallspeed = 0

const Speed = 120
var CurrentDir

var Alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	CurrentDir = -Speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Gravity()
	Move()
	Animate()
	move_and_slide()

func Gravity():
	if (!is_on_floor()):
		if (Fallspeed < 300):
			if (Fallspeed == 0):
				Fallspeed = 5
			else:
				Fallspeed = Fallspeed*1.2
	else:
		Fallspeed = 0
	
	velocity.y = Fallspeed

func Move():
	#Ledge Detection
	if ($LedgeDetection/LeftSight.is_colliding() == false):
		CurrentDir = Speed
	if ($LedgeDetection/RightSight.is_colliding() == false):
		CurrentDir = -Speed
	
	#Wall Detection
	if ($WallDetection/LeftWall.is_colliding()):
		CurrentDir = Speed
	if ($WallDetection/RightWall.is_colliding()):
		CurrentDir = -Speed
	velocity.x = CurrentDir

func Animate():
	if (velocity.x > 0):
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
	if (Alive):
		_Animator.play("Walk")
	else:
		velocity.x = 0
		_Animator.play("Death")

func _on_hurtbox_tree_exiting():
	Alive = false

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Death"):
		queue_free()
