extends CharacterBody3D

# 移動速度やジャンプ力などのパラメータ
@export var move_speed := 5.0
@export var jump_velocity := 10.0
@export var gravity := 20.0

var fall_timer := 0.0
var fall_sway_speed := 8.0
var fall_sway_amount := 0.1

var camera

var audioPlayer
var isAudioPlaying = false

func _ready():
	camera = get_parent().get_node("Camera3D")
	audioPlayer = $AudioStreamPlayer3D

func _physics_process(delta: float) -> void:
	var direction = get_input_direction()
	direction = direction.rotated(Vector3.UP, camera.rotation.y)

	# キャラクターを移動方向に向かせる（回転）
	# Y軸だけを使った回転（地面に対して水平）
	if direction.length_squared() > 0.01:
		var target_rotation = atan2(-direction.x, -direction.z)
		rotation.y = target_rotation
		if not audioPlayer.playing:
			audioPlayer.playing = true
	else:
		if audioPlayer.playing:
			audioPlayer.playing = false
	
	# 水平方向の移動
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# 重力を加える
	if not is_on_floor():
		if global_transform.origin.y < -50:
			$WindTrail.emitting = true
			fall_timer += delta
			var sway = sin(fall_timer * fall_sway_speed) * fall_sway_amount
			rotation.z = sway
			velocity.y = 0
		else:
			velocity.y -= gravity * delta
	else:
		# ジャンプ
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	move_and_slide()

func get_key_input_direction() -> Vector3:
	var dir = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	return dir.normalized()

func get_gamepad_input_direction() -> Vector3:
	var dir = Vector3.ZERO

	dir.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	dir.z = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	if dir.length_squared() < 0.1:
		dir = Vector3.ZERO
	
	return dir.normalized()

func get_input_direction() -> Vector3:
	var key_dir = get_key_input_direction()
	var gamepad_dir = get_gamepad_input_direction()

	var dir = key_dir + gamepad_dir
	
	return dir.normalized()
