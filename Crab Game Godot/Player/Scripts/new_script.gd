extends CharacterBody2D

var Delta = 0

#Player States:
var Stunned = false
var StunDelay = false
var XLocked = false
var YLocked = false
var GPing = false
var Punching = false
var Sprinting = false
var Idle = false
var Falling = false
var Invincible = false
var Weightless = false

#Variables for Combat:
const MaxHP = 3
var CurrentHP = MaxHP
var PunchCharged
var Attacking = false
var GPable = true
var KnockbackX = 1250
var KnockbackY = 1000

#Variables for Movement:
var WalkingMaxSpeed = 600
var RunningMaxSpeed = 1300
var CurrentMaxSpeed = WalkingMaxSpeed
var MaxFallSpeed = 3500
var PlayerXPosition
var PlayerYPosition
var GPBouncHeight = 3500
var BounceHeight = 2000

var Accel = 3500
var Decel = 6000
var Gravity = 6000
var JumpStrength = -1850
#was -2750 before changes to jumping.
var ChargePunchTimer
var Animator
var PunchHitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	ChargePunchTimer = $ChargePunch
	Animator = $Animations/AnimationPlayer
	PunchHitbox = $PunchHitbox
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	_StatusUpdate(delta)
	
	if (!Stunned):
		if (GPing):
			velocity.x = 0
		else:
			_MovementLogic()
		
	if (Input.is_action_just_pressed("Attack")):
		Attacking = true
		PunchCharged = false
		
		if (Input.is_action_pressed("ui_down")):
			_GroundPound()
		else:
			_BeginChargeAttack()
	
	if (Input.is_action_just_released("Attack")):
		if (Attacking):
			if (PunchCharged):
				_ChargePunch()
			else:
				_Punch()
	
	if (!GPing):
		if (!Weightless && !is_on_floor()):
			_GravityLogic()
	else:
		_GPPhysics()
	
	_AnimationHandler()
	
	move_and_slide()

func _Punch():
	Attacking = false
	Animator.play("Punch")
	

func _ChargePunch():
	pass

func _on_charge_punch_timeout():
	PunchCharged = true

func _BeginChargeAttack():
	ChargePunchTimer.start()

func _GPPhysics():
	velocity.y = 2000
	velocity.x = 0

func _GroundPound():
	Attacking = false
	velocity.x = 0
	GPing = true

func _GroundPoundReset():
	pass

func _StatusUpdate(delta):
	PlayerXPosition = global_position.x
	PlayerYPosition = global_position.y
	Delta = delta
	
	if (Input.is_action_pressed("Sprint")):
		Sprinting = true
		CurrentMaxSpeed = RunningMaxSpeed
	else:
		Sprinting = false
		CurrentMaxSpeed = WalkingMaxSpeed
	
	if (!is_on_floor()):
		
		if (GPing):
			GPing = false
		
		if (velocity.y > 0):
			Falling = true
		else:
			Falling = false
	else:
		GPable = true
		if (StunDelay == false):
			Stunned = false
		StunDelay = false

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
	
	
	
	if (Input.is_action_just_pressed("ui_up") && is_on_floor()):
		velocity.y = JumpStrength
		Weightless = true
		$JumpTimer.start()

	if (Input.is_action_just_released("ui_up") && !Falling):
		$JumpTimer.stop()
		Weightless = false

func _Decelerate():
	if (velocity.x != 0):
		if (abs(velocity.x) <= Decel*Delta):
			velocity.x = 0
		elif (velocity.x > 0):
			velocity.x -= Decel*Delta
			
		elif (velocity.x < 0):
			velocity.x += Decel*Delta

func _on_enemy_detection_area_entered(enemy):
	if ((PlayerYPosition < enemy.get_parent().global_position.y) && enemy.Stompable):
		enemy.TakeDamage(3)
		_Boing()
	else:
		_TakeDamage(enemy)
	
func _TakeDamage(enemy):
	CurrentHP -= enemy.GetDamage()
	_Knockback(enemy)
	if (CurrentHP == 0):
		_Die()

func _Knockback(enemy):
	Invincible = true
	Stunned = true
	StunDelay = true
	velocity.y = -KnockbackY
	position.y -= 10
	if (enemy.get_parent().global_position.x > PlayerXPosition):
		velocity.x = -KnockbackX
	else:
		velocity.x = KnockbackX

func _Stun():
	StunDelay = true
	Stunned = true

func _Boing():
	Stunned = false
	if (GPing == true):
		_GroundPoundReset()
		velocity.y = -GPBouncHeight
	else:
		velocity.y = -BounceHeight

func _Die():
	print("You Died")
	emit_signal("PlayerDied")
	queue_free()


func _on_jump_timer_timeout():
	Weightless = false

func _AnimationHandler():
	
	pass


func _on_punch_hitbox_area_entered(area):
	if (area.is_in_group("Enemies")):
		area.TakeDamage(3)
