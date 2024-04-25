extends CharacterBody2D

@onready var _Animator = $Sprite2D/AnimationPlayer
@onready var _Collision = $Physics
var Fallspeed = 0

const Speed = 230
var CurrentDir

var MaxFallSpeed = 400

var Alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	CurrentDir = -Speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Alive):
		Gravity()
		Move()
		Animate()
		move_and_slide()
		LedgePhysics()
	else:
		velocity.y = 0

func Gravity():
	if (!is_on_floor()):
		if (Fallspeed < MaxFallSpeed):
			if (Fallspeed == 0):
				Fallspeed = 1
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
	_Animator.play("Walk")

func _on_hurtbox_tree_exiting():
	Die()

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Death"):
		queue_free()

func Die():
	Alive = false
	velocity.x = 0
	_Animator.play("Death")
	_Collision.disabled = true

func LedgePhysics():
	floor_max_angle = 0.9
	floor_constant_speed = true
	floor_snap_length = 15.0
	apply_floor_snap()

	var testA = Vector2(1, 1)
	var rotate=(get_floor_angle())
	var PoRotate=(get_floor_normal())
	var OpRotate = -PoRotate
	var game = OpRotate.dot(testA)

	if is_on_floor():
		if game < 1.1:
			$Sprite2D.rotation = rotate
		if game > 0.9:
			$Sprite2D.rotation = -rotate
	else:
		$Sprite2D.rotation = $Sprite2D.rotation - $Sprite2D.rotation*0.10
	
