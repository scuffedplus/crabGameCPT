extends CharacterBody2D

const MaxWalkSpeed = 250
const MaxRunSpeed = 600
const Accel = 100
#CHANGE FOR CHRISTOPHER'S THING TO WORK
var Decel = 3
const MinDecel = 3

# The amount the deceleration exponentially increases by.
const DecelMultiplier = 1.75

const MaxDecel = 25
const JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*2


func _physics_process(delta):
	
#JUMPING CODE
	var HoldingMove = Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

#LEFT AND RIGHT ACCELLERATION CODE
	if (Input.is_key_pressed(KEY_SHIFT)):
		if (Input.is_action_pressed("ui_left")):
			if (velocity.x > -MaxRunSpeed && velocity.x <= 0):
				velocity.x -= Accel
	
		if (Input.is_action_pressed("ui_right")):
			if (velocity.x < MaxRunSpeed && velocity.x >= 0):
				velocity.x += Accel
	else:
		
		if (abs(velocity.x) > MaxWalkSpeed):
			if (velocity.x > 0):
				velocity.x -= Decel
			else:
				velocity.x += Decel
		
		if (Input.is_action_pressed("ui_left")):
			if (velocity.x > -MaxWalkSpeed && velocity.x <= 0):
				velocity.x -= Accel
	
		if (Input.is_action_pressed("ui_right")):
			if (velocity.x < MaxWalkSpeed && velocity.x >= 0):
				velocity.x += Accel
#LEFT AND RIGHT DECELLERATION CODE

	if (velocity.x <= Decel && velocity.x >= -Decel):
		if (!HoldingMove):
			velocity.x = 0
			Decel = MinDecel
	else:
		#IF MOVING RIGHT AND HOLDING LEFT DECELERATE
		if (velocity.x > Decel && Input.is_action_pressed("ui_left")):
			velocity.x -= Decel
		#IF MOVING LEFT AND HOLDING RIGHT DECELERATE
		if (velocity.x < 0 && Input.is_action_pressed("ui_right")):
			velocity.x += Decel
		#IF HOLDING NOTHING DECELRATE
		if (!HoldingMove):
			if (velocity.x > Decel):
				velocity.x -= Decel
			if (velocity.x < -Decel):
				velocity.x += Decel
			if (Decel < MaxDecel):
				Decel = Decel * DecelMultiplier

	move_and_slide()
