extends CharacterBody3D

const GRAVITY = -24.8
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 20

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	#if is_on_floor():
		#if Input.is_action_just_pressed("movement_jump"):
			#velocity.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	#velocity.y += delta * GRAVITY

	var hvel = velocity
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.lerp(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

#
#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#
#
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
