extends KinematicBody2D


const GRAVITY = 320
const DEACCEL = 6
const ACCEL = 4
const MAX_SPEED = 190

var velocity_mov_lane = 40
var sizeSprite = Vector2(32,32)
var vel = Vector2()
var dir = Vector2()
var lane = 1
var change_lane = 0
var anim = "Idle"
var current_anim = ""
var angle_bike = 0
var frame = 0
var tilt_angle = 0
var tilt_active = false

func _ready():
	$Sprite.position.y = (lane*-12)
	pass
	
func _physics_process(delta):
	angle_bike = round(rad2deg(get_floor_normal().angle()) + 90.1)
	_input_moviment(delta)
	_physics_moviment(delta)
	_lane_motorcycle(delta)
	_tilt_angle()
	set_animation(anim)
	frame +=delta
	print(delta)
	print(Engine.get_frames_per_second())
	
func _physics_moviment(delta):
	vel.y += GRAVITY * delta
	var hvel = vel
	hvel.y = 0
	
	var acceleration = DEACCEL
	if dir.dot(hvel) > 0:
		acceleration = ACCEL
	
	if vel.x < 10:
		anim = "Idle"
		
	var target = dir * MAX_SPEED
	
	hvel = hvel.linear_interpolate(target, acceleration * delta)
	vel.x = hvel.x
	vel = move_and_slide(vel, Vector2.UP, false, 4, PI/2)
	
func _input_moviment(delta):
	dir = Vector2()
	
	if Input.is_action_pressed("ui_accept"):
		dir.x += 1
		if angle_bike == 0:
			anim = "Run"
	dir = dir.normalized()
	tilt_active = Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")
	
	
	if Input.is_action_pressed("ui_right"):
		tilt_angle += 5
		
	if Input.is_action_pressed("ui_left"):
		tilt_angle -= 5 
		
	tilt_angle = clamp(tilt_angle, -90, 60)
	
	if is_on_floor() and angle_bike == 0:
		if Input.is_action_just_pressed("ui_up"):
			change_lane = -1
			lane += 1
		if Input.is_action_just_pressed("ui_down"):
			change_lane = 1
			lane -= 1
	
func _lane_motorcycle(delta):
	if change_lane:
		anim = "Up"
		if change_lane == 1:
			anim = "Down"
		$Sprite.translate(Vector2(0,change_lane) * velocity_mov_lane * delta)
	
		if int($Sprite.position.y) == (lane*-12):
			if lane < 1:
				lane = 1
				change_lane = -1
			elif lane > 4:
				lane = 4
				change_lane = 1
			else:
				change_lane = 0
	
func _tilt_angle():
	if !tilt_active and tilt_angle:
		tilt_angle += (sign(tilt_angle)*3)*-1
	

	if tilt_angle:
		var tmp = str(tilt_angle)
		if (tmp in $AnimationPlayer.get_animation_list()):
			anim = tmp
		else:
			anim = current_anim
	
	print(angle_bike)
	
	
func set_animation(animation):
	if current_anim != animation:
		current_anim = animation
		$AnimationPlayer.current_animation = current_anim
