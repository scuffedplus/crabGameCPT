extends CharacterBody2D

var Delta = 0

#Player States:
var Stunned = false
var XLocked = false
var YLocked = false
var GPing = false
var Punching = false
var Sprinting = false
var Idle = false
var Rising = false
var Falling = false

#Variables for Movement:
var WalkingMaxSpeed = 600
var RunningMaxSpeed = 1300
var CurrentMaxSpeed = WalkingMaxSpeed
var MaxFallSpeed = 1750

var Accel = 3500
var Decel = 6000
var Gravity = 6000
var JumpStrength = -2750

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_StatusUpdate(delta)
	_MovementLogic()
	move_and_slide()

func _StatusUpdate(delta):
	Delta = delta
	if (Input.is_key_pressed(KEY_SHIFT)):
		Sprinting = true
		CurrentMaxSpeed = RunningMaxSpeed
	else:
		Sprinting = false
		CurrentMaxSpeed = WalkingMaxSpeed
	
	if (!is_on_floor()):
		_GravityLogic()
		if (velocity.y > 0):
			Falling = true
		else:
			Rising = true

func _GravityLogic():
	if (velocity.y < MaxFallSpeed):
		velocity.y += Gravity*Delta

func _MovementLogic():
	if (Input.is_action_pressed("ui_right")):
		Idle = false
		
		if (velocity.x < 0):
			_Decelerate()
		
		if (velocity.x <= CurrentMaxSpeed):
			velocity.x += Accel*Delta
	elif (Input.is_action_pressed("ui_left")):
		Idle = false
		
		if (velocity.x > 0):
			_Decelerate()
		
		if (velocity.x >= -CurrentMaxSpeed):
			velocity.x -= Accel*Delta
	else :
		Idle = true
	
	if ((Idle or velocity.x > CurrentMaxSpeed)):
		_Decelerate()
	
	if (Input.is_key_pressed(KEY_Z) && is_on_floor()):
		velocity.y = JumpStrength
	
	
func _Decelerate():
	if (velocity.x != 0):
		if (abs(velocity.x) <= Decel*Delta):
			velocity.x = 0
		elif (velocity.x > 0):
			velocity.x -= Decel*Delta
			
		elif (velocity.x < 0):
			velocity.x += Decel*Delta
