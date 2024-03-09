extends CharacterBody2D

var Midair
var FacingRight
const GPSpeed = -1200

const Bounce = -750
const GPBounce = -1200

var PlayerPosition = position.x

const MaxHP = 3
var CurrentHP = 300

const MaxWalkSpeed = 250
const MaxRunSpeed = 600
var Accel = 100
const WalkAccel = 100

var Decel = 3
const MinDecel = 3
# The amount the deceleration exponentially increases by.
const DecelMultiplier = 1.75
var MaxDecel = 25
#The maximum deceleration changes depending on whether the player is grounded.
const MidAirMaxDecel = 8
const OnGroundMaxDecel = 25

const JUMP_VELOCITY = -1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*2

#Different States for the player are below:
var Poundability = true

#NOTE:
#Currently, IF it is NOT POSSIBLE TO GROUNDPOUND
#IT IS ASSUMED that the player is MID-GROUNDPOUND


#If stunned (can't move left and right)
var Stunned = false
var StunDelay = false

#NOTE:
#Stunned is set to false if touching the ground
#StunDelay is there because getting knocked back sets Stunned to true and knocks the player back
#BUT if the player is on the floor, Stunned is immediately set back to false
#StunDelay is used to delay the inversion of Stunned by one frame if enabled
#This will probably break something down the line but we'll cross that bridge when we get to it.

#If invicible
var Invicible = false

"""
ALL of the above variables are used by the groundpound script.
It's a bit of a mess.
NOTE:
"""

func _physics_process(delta):
	
	PlayerPosition = position.x

	Midair = !is_on_floor()
	
#JUMPING CODE
	var HoldingMove = Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")
	
	if (Midair):
		MaxDecel = MidAirMaxDecel
		if (Poundability):
			velocity.y += gravity * delta
	else:
		MaxDecel = OnGroundMaxDecel
		if (Poundability == false):
			UnGroundPound()
		Invicible = false
		if (StunDelay == false):
			if (Stunned):
				Stunned = false
	
	StunDelay = false
	
	if (Stunned == true):
		Accel = 0
	else:
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
				FacingRight = false
	
		if (Input.is_action_pressed("ui_right")):
			if (velocity.x < MaxRunSpeed && velocity.x >= 0):
				velocity.x += Accel
				FacingRight = true
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
	Stunned = true
	print("Stunned!")
	await get_tree().create_timer(0.10).timeout
	velocity.y -= GPSpeed

#Resets the player after a groundpound
func UnGroundPound():
	print("Acceleration Reset")
	Poundability = true

func TakeDamage(Damager):
	CurrentHP -= Damager.GetDamage()
	print("Youch!!!")
	Knockback(Damager)
	if (CurrentHP == 0):
		die()

func die():
	print("You Died")
	emit_signal("PlayerDied")
	queue_free()

#ON CONTACT WITH AN OUCHIE:
func _on_enemy_detection_area_entered(area):
	if (velocity.y <= 0):
		TakeDamage(area)
	else:
		if (area.is_in_group("Enemies")):
			area.TakeDamage(3)
		Boing()

func punch():
	#if you guys want to code this we need an animation first
	#easiest way I found is to make a hitbox appear from frame x to frame y
	pass

func Boing():
	if (Poundability == false):
		UnGroundPound()
		velocity.y = -velocity.y*1.25
	else:
		velocity.y = -velocity.y

#Returns true if the player is attempting to move to the right (X+)
func MovingRight():
	return(FacingRight)


#IGNORE THE BROKEN CODE
func Knockback(Enemy):
	Invicible = true
	print("Invincible!")
	Stunned = true
	StunDelay = true
	print("Stunned!")
	var EnemyPosition = Enemy.get_parent().position.x
	velocity.y = -700
	position.y -= 10
	
	if (EnemyPosition > PlayerPosition):
		velocity.x = -700
	if (EnemyPosition < PlayerPosition):
		velocity.x = 700
