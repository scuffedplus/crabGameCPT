extends CharacterBody2D

var Midair

const GPSpeed = -1000

const MaxHP = 3
var CurrentHP = 3

const MaxWalkSpeed = 250
const MaxRunSpeed = 600
var Accel = 100
const GPAccel = 0
const WalkAccel = 100
#CHANGE FOR CHRISTOPHER'S THING TO WORK
var Decel = 3
const MinDecel = 3

# The amount the deceleration exponentially increases by.
const DecelMultiplier = 1.75

const MaxDecel = 25
const JUMP_VELOCITY = -1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*2

var Poundability = true

func _physics_process(delta):
	
	Midair = !is_on_floor()
	
#JUMPING CODE
	var HoldingMove = Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")
	
	if (Midair):
		if (Poundability):
			velocity.y += gravity * delta
	else:
		Poundability = true
		Accel = WalkAccel

#ATTACKING LOGIC
	if (Input.is_key_pressed(KEY_X)):
		if (Input.is_action_pressed("ui_down")):
			if (Midair && Poundability):
				GroundPound()
		else:
			if (Input.is_action_pressed("ui_up")):
				punch()
				

#JUMPING LOGIC
	if (Input.is_key_pressed(KEY_Z) and is_on_floor()):
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

func GroundPound():
	Poundability = false
	velocity.y = 0
	velocity.x = 0
	Accel = GPAccel
	await get_tree().create_timer(0.25).timeout
	velocity.y -= GPSpeed

func die():
	print("You Died")
	emit_signal("PlayerDied")
	queue_free()


func _on_enemy_detection_area_entered(area):
	if (velocity.y <= 0):
		CurrentHP -= 1
		print("Youch!!!")
		if (CurrentHP == 0):
			die()
	else:
		if (area.is_in_group("Enemies")):
			area.TakeDamage(3)

func punch():
	pass
