extends CharacterBody3D


@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002
@export var gravity := 9.8

var camera_x_rotation := 0.0

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Jump
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = jump_velocity

	# Movement input
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate player left/right
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotate camera up/down
		camera_x_rotation -= event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = camera_x_rotation

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			self.set_physics_process(false)
			self.set_process_input(false)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			self.set_process_input(true)
			self.set_physics_process(true)
