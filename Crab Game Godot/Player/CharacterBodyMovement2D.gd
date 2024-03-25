extends CharacterBody2D

#Each item in this list corresponds to an animation
#Closer to first means higher priority
#If no conditions are met plays idle animation
var AnimPriority = [Punching, GroundPounding, Midair, Walking, true]
var AnimNames = ["Punch", "GroundPound", "Jump", "Walk", "Idle"]
#Animatable player states
var Walking
#Midair is also used for some other things with jumping/bouncing
var Midair
var Punching
var GroundPounding

var JumpState = false

var FacingRight
const GPSpeed = -1200

const Bounce = -750
const GPBounce = -1200

#Gets the animatino player and makes it a variable
@onready var animation = $Sprite2D/AnimationPlayer

var PlayerPosition = position.x

const MaxHP = 3
var CurrentHP = 3

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

#If Invincible
var Invincible = false

"""
ALL of the above variables are used by the groundpound script.
It's a bit of a mess.
"""

func _physics_process(delta):
	animation.play("Walk", 1, 1.0, true)
	var Walking = false
	var Midair = false
	var Punching = false
	var GroundPounding = false
	
	PlayerPosition = position.x

	Midair = !is_on_floor()
	
#JUMPING CODE
	var HoldingMove = Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")
	
	if (Midair):
		MaxDecel = MidAirMaxDecel
		if (Poundability):
			velocity.y += gravity * delta
	else:
		JumpState = false
		MaxDecel = OnGroundMaxDecel
		if (Poundability == false):
			UnGroundPound()
		if (StunDelay == false):
			Invincible = false
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
			if (Midair && Poundability && !Stunned):
				GroundPound()
		else:
			punch()
				

#JUMPING LOGIC
	if (Input.is_key_pressed(KEY_Z) and is_on_floor()):
		velocity.y = JUMP_VELOCITY
		JumpState = true
	if (JumpState):
		if (!Input.is_key_pressed(KEY_Z) && velocity.y < 0):
			velocity.y = velocity.y/10

#LEFT AND RIGHT ACCELLERATION CODE
	if (Input.is_key_pressed(KEY_SHIFT)):
		if (Input.is_action_pressed("ui_left")):
			if ((velocity.x > -MaxRunSpeed && velocity.x <= 0) or (Midair && velocity.x > -MaxRunSpeed)):
				velocity.x -= Accel
				FacingRight = false
	
		if (Input.is_action_pressed("ui_right")):
			if ((velocity.x < MaxRunSpeed && velocity.x >= 0) or (Midair && velocity.x < MaxRunSpeed)):
				velocity.x += Accel
				FacingRight = true
	else:
		
		if (abs(velocity.x) > MaxWalkSpeed):
			if (velocity.x > 0):
				velocity.x -= Decel
			else:
				velocity.x += Decel
		
		#Accelerate to the left unless moving right OR midair. Speed limited to MaxWalkSpeed
		if (Input.is_action_pressed("ui_left")):
			if ((velocity.x > -MaxWalkSpeed && velocity.x <= 0) or (Midair && velocity.x > -MaxWalkSpeed)):
				velocity.x -= Accel
		
		#Accelerate to the rightx unless moving left OR midair. Speed limited to MaxWalkSpeed
		if (Input.is_action_pressed("ui_right")):
			if ((velocity.x < MaxWalkSpeed && velocity.x >= 0) or (Midair && velocity.x < MaxWalkSpeed)):
				velocity.x += Accel

#LEFT AND RIGHT DECELLERATION CODE

#Decelerates if grounded and not holding an input
#Also some very messed up code to make the rate of deceleration exponential
	if (!Midair):
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
	
	for i in len(AnimPriority):
		if (AnimPriority[i] == true):
			animation.play(AnimNames[i])
			break
	move_and_slide()

func GroundPound():
	Poundability = false
	velocity.y = 0
	velocity.x = 0
	Stunned = true
	await get_tree().create_timer(0.10).timeout
	velocity.y -= GPSpeed

func UnGroundPound():
	Poundability = true
	Stunned = false

func TakeDamage(Damager):
	if (Invincible == false):
		CurrentHP -= Damager.GetDamage()
		print("Youch!!!")
		if (CurrentHP == 0):
			die()
	Knockback(Damager)

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
	animation.play("Punch")
	#if you guys want to code this we need an animation first
	#easiest way I found is to make a hitbox appear from frame x to frame y
	pass

#Called when bouncing on an enemy
#Checks whether the player was groundpounding
func Boing():
	JumpState = false
	Stunned = false
	if (Poundability == false):
		UnGroundPound()
		velocity.y = -velocity.y
	else:
		velocity.y = -velocity.y

#Returns true if the player is attempting to move to the right (X+)
func MovingRight():
	return(FacingRight)

#IGNORE THE BROKEN CODE
func Knockback(Enemy):
	Invincible = true
	Stunned = true
	StunDelay = true
	var EnemyPosition = Enemy.get_parent().position.x
	velocity.y = -700
	position.y -= 10
	if (EnemyPosition > PlayerPosition):
		velocity.x = -700
	if (EnemyPosition < PlayerPosition):
		velocity.x = 700
