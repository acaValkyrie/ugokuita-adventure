extends CharacterBody3D

# 移動速度やジャンプ力などのパラメータ
@export var move_speed := 5.0
@export var jump_velocity := 4.0
@export var gravity := 20.0

func _physics_process(delta: float) -> void:
	var input_dir = get_input_direction()
	var direction = input_dir.normalized()
	
	# キャラクターを移動方向に向かせる（回転）
	# Y軸だけを使った回転（地面に対して水平）
	if direction.length_squared() > 0.01:
		var target_rotation = atan2(-direction.x, -direction.z)
		rotation.y = target_rotation
	
	# 水平方向の移動
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# 重力を加える
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# ジャンプ
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	move_and_slide()
	

func get_input_direction() -> Vector3:
	var dir = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	return dir
