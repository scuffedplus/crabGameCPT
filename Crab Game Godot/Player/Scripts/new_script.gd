extends CharacterBody2D

#Player States:
var FacingRight = true
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
var WallSliding = false

#Variables for Combat:
const MaxHP = 3
var CurrentHP = MaxHP
var PunchCharged
var Attacking = false
var GPable = true
var KnockbackX = 1250
var KnockbackY = 1000

#Variables for Movement:
var WalkingMaxSpeed = 1000
var RunningMaxSpeed = 1800
var CurrentMaxSpeed = WalkingMaxSpeed
var MaxFallSpeed = 3500
var PlayerXPosition
var PlayerYPosition
var GPSpeed = 4000
var GPBouncHeight = 3000
var BounceHeight = 1500
var MaxWallSlideSpeed = 1000
var WallSlideAccel = 6000
var GPMomentum = false

var Accel = 3500
var Decel = 6000
var Gravity = 6000
var JumpStrength = -1850
var GPMomentumJump = JumpStrength*1.5
#was -2750 before changes to jumping.
var CoyoteComplete

var ChargePunchTimer
var Sprite
var Animator
var PunchHitbox
var GPMomentumTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	Sprite = $Animations
	ChargePunchTimer = $ChargePunch
	Animator = $Animations/AnimationPlayer
	PunchHitbox = $PunchHitbox
	GPMomentumTimer = $GPMomentum
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	_StatusUpdate(delta)
	
	if (!Stunned):
		if (GPing):
			velocity.x = 0
		else:
			_MovementLogic(delta)
		
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
		if (!Weightless && !is_on_floor() && $CoyoteTime.is_stopped()):
			_GravityLogic(delta)
	else:
		_GPPhysics()
	
	_AnimationHandler()
	move_and_slide()

func _Punch():
	Attacking = false
	Punching = true
	Animator.play("Punch")
	if !FacingRight:
		$PunchHitbox/PunchCollider.position.x = -227
	else:
		$PunchHitbox/PunchCollider.position.x = 227
	

func _ChargePunch():
	pass

func _on_charge_punch_timeout():
	PunchCharged = true

func _BeginChargeAttack():
	ChargePunchTimer.start()

func _GPPhysics():
	velocity.y = GPSpeed
	velocity.x = 0

func _GroundPound():
	Attacking = false
	velocity.x = 0
	GPing = true

func _GroundPoundReset():
	GPing=false
	GPMomentumTimer.start()
	GPMomentum = true
	print("GPing Reset _GroundPoundReset")

func _StatusUpdate(delta):
	
	if !FacingRight:
		Sprite.flip_h = true
	else:
		Sprite.flip_h = false
	
	PlayerXPosition = global_position.x
	PlayerYPosition = global_position.y
	
	if (Input.is_action_pressed("Sprint")):
		Sprinting = true
		CurrentMaxSpeed = RunningMaxSpeed
	else:
		Sprinting = false
		CurrentMaxSpeed = WalkingMaxSpeed
	
	if (!is_on_floor()):
		
		if (!CoyoteComplete):
			_CoyoteTimeStart()
		
		if (velocity.y > 0):
			Falling = true
		else:
			Falling = false
	else:
		if GPing:
			_GroundPoundReset()
			
		GPable = true
		CoyoteComplete = false
		if (StunDelay == false):
			Stunned = false
		StunDelay = false

func _GravityLogic(delta):
	if (velocity.y < MaxFallSpeed):
		velocity.y += Gravity*delta

func _MovementLogic(delta):
	if (Input.is_action_pressed("ui_right")):
		FacingRight = true
		Idle = false
		
		if (velocity.x < 0):
			_Decelerate(delta)
		
		if (velocity.x <= CurrentMaxSpeed):
			velocity.x += Accel*delta
	elif (Input.is_action_pressed("ui_left")):
		FacingRight=false
		Idle = false
		
		if (velocity.x > 0):
			_Decelerate(delta)
		
		if (velocity.x >= -CurrentMaxSpeed):
			velocity.x -= Accel*delta
	else :
		Idle = true
	
	if ((Idle or velocity.x > CurrentMaxSpeed)):
		_Decelerate(delta)
	
	if (Input.is_action_just_pressed("ui_up") && (is_on_floor() or !$CoyoteTime.is_stopped())):
		if !GPMomentum:
			velocity.y = JumpStrength
		else:
			velocity.y = GPMomentumJump
		Weightless = true
		$JumpTimer.start()
		
#Wall sliding code
	if (is_on_wall_only() && velocity.y > 0):
		WallSliding = true
		if (velocity.y > MaxWallSlideSpeed):
			velocity.y -= WallSlideAccel*delta
	else:
		WallSliding = false
	
	if (WallSliding == true):
		print(WallSliding)

	if (Input.is_action_just_released("ui_up") && !Falling):
		$JumpTimer.stop()
		Weightless = false

func _Decelerate(delta):
	if (velocity.x != 0):
		if (abs(velocity.x) <= Decel*delta):
			velocity.x = 0
		elif (velocity.x > 0):
			velocity.x -= Decel*delta
			
		elif (velocity.x < 0):
			velocity.x += Decel*delta

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
		print("BOING!")
		_GroundPoundReset()
		velocity.y = -GPBouncHeight
	else:
		print("Boing!!")
		velocity.y = -BounceHeight

func _Die():
	print("You Died")
	emit_signal("PlayerDied")
	queue_free()


func _on_jump_timer_timeout():
	Weightless = false

func _AnimationHandler():
	if !Punching:
		if velocity.y > 0:
			Animator.play("Fall")
		elif velocity.y < 0:
			Animator.play("Jump")
		elif velocity.x == 0:
			Animator.play("Idle")
		elif velocity.x > WalkingMaxSpeed:
			Animator.play("Run")
		else:
			Animator.play("Walk")

func _CoyoteTimeStart():
	$CoyoteTime.start()
	CoyoteComplete = true

func _on_punch_hitbox_area_entered(area):
	if (area.is_in_group("Enemies")):
		area.TakeDamage(3)


func _on_gp_momentum_timeout():
	GPMomentum = false


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Punch":
		Punching = false
		print("Done Punching")
