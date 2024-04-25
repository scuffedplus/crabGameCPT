extends CharacterBody2D



var Punching = false
var Falling = false

var Midair
var FacingRight
const GPSpeed = -1200


var Comboing = false
#If Currently in a combo
var ComboHit = 0
#Which hit of the combo

const Bounce = -750
const GPBounce = -1200

@onready var _Walk = $Animations/AnimationPlayer
@onready var PunchCoolDown = $PunchCoolDown

var Inventory = [0, 0, 0, 0, 0, 0]

"""
0 = Coins
1 = Gold Keys
2 = Red Keys
3 = Blue Keys
4 = Gold Coins
"""

var PlayerPosition = position.x

const MaxHP = 3
var CurrentHP = 20000
var JumpState = false
const MaxWalkSpeed = 700
const MaxRunSpeed = 1200
var Accel = 100
const WalkAccel = 100
var floorDir = get_floor_normal
var Decel = 3
const MinDecel = 3
# The amount the deceleration exponentially increases by.
const DecelMultiplier = 1.75
var MaxDecel = 25
#The maximum deceleration changes depending on whether the player is grounded.
const MidAirMaxDecel = 8
const OnGroundMaxDecel = 25

const JUMP_VELOCITY = -1200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*2

#Different States for the player are below:
var Poundability = true
#Currently, IF it is NOT POSSIBLE TO GROUNDPOUND
#IT IS ASSUMED that the player is MID-GROUNDPOUND
var Stunned = false
#If stunned (can't move left and right)
var StunDelay = false
#Stunned is set to false if touching the ground
#StunDelay is there because getting knocked back sets Stunned to true and knocks the player back
#BUT if the player is on the floor, Stunned is immediately set back to false
#StunDelay is used to delay the inversion of Stunned by one frame if enabled
#This will probably break something down the line but we'll cross that bridge when we get to it.
var FullStun = false
#Like stun, but doesn't reset when touching the ground.
var Ylocked = false
#locks the players y position
#If invicible
var Invicible = false

"""
ALL of the above variables are used by the groundpound script.
It's a bit of a mess.
NOTE:
"""

func _physics_process(delta):

	Midair = !is_on_floor()
	
#JUMPING CODE
	var HoldingMove = Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_left")
	
	if (Midair):
		if (Ylocked):
			velocity.y = 0
		else:
			MaxDecel = MidAirMaxDecel
			if (Poundability):
				velocity.y += gravity * delta
	else:
		JumpState = false
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
			if (Midair && Poundability && !Stunned && !Punching):
				GroundPound()
		else:
			if (PunchCoolDown.is_stopped() && !Punching && !Stunned):
				punch()

#JUMPING LOGIC
	if (Input.is_key_pressed(KEY_Z) and is_on_floor()):
		velocity.y = JUMP_VELOCITY
		JumpState = true
	if (JumpState):
		if (!Input.is_key_pressed(KEY_Z) && velocity.y < 0):
			velocity.y = velocity.y/2

#LEFT AND RIGHT ACCELLERATION CODE
	if (FullStun == false):
		if (Input.is_key_pressed(KEY_SHIFT)):
			if (Input.is_action_pressed("ui_left")):
				$Animations.flip_h = true
				_Walk.play("Run")
				if ((velocity.x > -MaxRunSpeed && velocity.x <= 0) or (Midair && velocity.x > -MaxRunSpeed)):
					velocity.x -= Accel
					FacingRight = false
					
			if (Input.is_action_pressed("ui_right")):
				$Animations.flip_h = false
				_Walk.play("Run")
				if ((velocity.x < MaxRunSpeed && velocity.x >= 0) or (Midair && velocity.x < MaxRunSpeed)):
	
					velocity.x += Accel
					
					FacingRight = true
		else:
			if (abs(velocity.x) > MaxWalkSpeed):
				if (velocity.x > 0):
					velocity.x -= Decel
				else:
					velocity.x += Decel
			
			#Accelerate to the left unless moving right OR midair. Speed limited to MaxWalkSpeedS
			
			if (Input.is_action_pressed("ui_left")):
				$Animations.flip_h = true
				FacingRight = false
				_Walk.play("Walk")
				if ((velocity.x > -MaxWalkSpeed && velocity.x <= 0) or (Midair && velocity.x > -MaxWalkSpeed)):
					velocity.x -= Accel

			#Accelerate to the right unless moving left OR midair. Speed limited to MaxWalkSpeed

			if (Input.is_action_pressed("ui_right")):
				$Animations.flip_h = false
				FacingRight = true
				_Walk.play("Walk")
				if ((velocity.x < MaxWalkSpeed && velocity.x >= 0) or (Midair && velocity.x < MaxWalkSpeed)):
					velocity.x += Accel

				
	if !(Input.is_action_pressed("ui_right")) and !(Input.is_action_pressed("ui_left")):
		if ((_Walk.current_animation == "Walk") or (_Walk.current_animation == "Run")):
			_Walk.play("Idle")
	else:
		if (velocity.y > 1):
			_Walk.play("Fall")
		elif (velocity.y < -1):
			_Walk.play("Jump")
		else:
			_Walk.play("Idle")

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
	
	move_and_slide()
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
			$Animations.rotation = rotate
		if game > 0.9:
			$Animations.rotation = -rotate
	else:
		$Animations.rotation = $Animations.rotation - $Animations.rotation*0.10
		


func MovingRight():
	return(FacingRight)

"""
COMBAT, ITEMS, ENEMIES
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"""
		
func _on_collectible_detection_area_entered(area):
	var CollectibleInfo = area.GetInfo()
	
	print(CollectibleInfo)
	print(Inventory[CollectibleInfo[0]])
	
	Inventory[CollectibleInfo[0]] += 1
	
	print(Inventory[CollectibleInfo[0]])
	
	if (CollectibleInfo[2]):
		area.Die()
		
	if (CollectibleInfo[0] == 0):
		for n in CollectibleInfo[1]:
			Inventory[CollectibleInfo[0]] += 1
			print(Inventory[CollectibleInfo[0]])
			
	if (CollectibleInfo[0] == 5):
		print("YOU WIN!")
		pass

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

	
func Knockback(Enemy):
	Invicible = true
	Stunned = true
	StunDelay = true
	var EnemyPosition = Enemy.get_parent().global_position.x
	PlayerPosition = global_position.x
	velocity.y = -700
	position.y -= 10
	if (EnemyPosition > PlayerPosition):
		velocity.x = -700
	if (EnemyPosition < PlayerPosition):
		velocity.x = 700


func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Punch"):
		Punching = false
		FullStun = false
		Ylocked = false

func PunchReset():
	FullStun = false
	Ylocked = false
	_Walk.play("Idle")
	$PunchCoolDown.start()
	ComboHit = 0
	$PunchHitbox.scale.x = 1
	

func _on_punch_hitbox_area_entered(area):
	if (area.is_in_group("Enemies")):
		area.TakeDamage(3)


func _on_timer_timeout():
	Comboing = false
	Punching = false
	PunchReset()

func punch():
	if (!FacingRight):
		$PunchHitbox.scale.x = -1
	_Walk.play("Punch")
	velocity.x = velocity.x/10
	FullStun = true
	Ylocked = true
	ComboHit += 1
	Comboing = true
	Punching = true
	$ComboTimer.start()
	if (ComboHit == 4):
		PunchReset()
