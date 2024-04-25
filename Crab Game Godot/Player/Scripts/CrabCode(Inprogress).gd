extends CharacterBody2D
#Basic Variables:
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*2

#Player States:
var PlayerPosition = position.x
var Midair = false
var HoldingNothing = false
#Whether the player is groundpounding:
var GPounding = false
var Jumping = false
var Invincible = false
var Stunned = false
#Needed for Stunned to work correctly dont worry about it.
var StunDelay = false

#Deceleration and Acceleration Values:
var Decel = 3
const MinDecel = 3
# The amount the deceleration exponentially increases by.
const DecelMultiplier = 1.75
var MaxDecel = 25
#The maximum deceleration changes depending on whether the player is grounded.
const MidAirMaxDecel = 8
const OnGroundMaxDecel = 25


func _physics_process(delta):
	#updates variables that need constant updates (whether midair, current position, etc.)
	StateCheck()
	
	if (Midair):
		MaxDecel = MidAirMaxDecel
		if (!GPounding):
			velocity.y += gravity * delta
	else:
		Jumping = false
		MaxDecel = OnGroundMaxDecel
		#if (GPounding == false):
			#UnGroundPound()
		#Invicible = false
		if (StunDelay == false):
			if (Stunned):
				Stunned = false
	
	pass

func StateCheck():
	PlayerPosition = position.x
	Midair = !is_on_floor()
	HoldingNothing = !(Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left"))
