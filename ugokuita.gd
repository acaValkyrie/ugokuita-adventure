extends CharacterBody3D

# 移動速度やジャンプ力などのパラメータ
@export var move_speed := 5.0
@export var jump_velocity := 10.0
@export var gravity := 20.0

var fall_stop_height = -100
var fall_timer := 0.0
var fall_sway_speed := 8.0
var fall_sway_amount := 0.1

var camera

var audioPlayer
var isAudioPlaying = false
var spotLight
var isPressed = false

var wind_trail

var virtual_joystick_L

func _ready():
    camera = get_parent().get_node("Camera3D")
    audioPlayer = $AudioStreamPlayer3D
    spotLight = $SpotLight3D
    wind_trail = $WindTrail
    virtual_joystick_L = get_parent().get_node("CanvasLayer/JoyStick_L")

func _physics_process(delta: float) -> void:    
    var direction = get_input_direction()
    direction = direction.rotated(Vector3.UP, camera.rotation.y)
    var is_moving: bool = direction.length_squared() > 0.01

    # キャラクターを移動方向に向かせる（回転）
    # Y軸だけを使った回転（地面に対して水平）
    if is_moving:
        var target_rotation = atan2(-direction.x, -direction.z)
        rotation.y = target_rotation
    
    # 水平方向の移動
    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed

    # ジャンプの処理
    if is_on_floor():
        if Input.is_action_just_pressed("jump"):
            velocity.y = jump_velocity
    else:
        if global_transform.origin.y >= fall_stop_height:
            # 重力を加える
            velocity.y -= gravity * delta

    # 音声の再生制御
    if is_moving:
        if not audioPlayer.playing:
            audioPlayer.playing = true
    else:
        if audioPlayer.playing:
            audioPlayer.playing = false
    
    toggle_head_light()
    
    if global_transform.origin.y < fall_stop_height:
        wind_trail.emitting = true
        fall_timer += delta
        var sway = sin(fall_timer * fall_sway_speed) * fall_sway_amount
        rotation.z = sway
        velocity.y = 0
        
    move_and_slide()

func toggle_head_light():
    if Input.is_action_pressed("toggle_head_light"):
        if isPressed == false:
            isPressed = true
            var currentVisible = spotLight.visible
            spotLight.visible = not currentVisible
    else:
        isPressed = false

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

func get_virtual_input_direction() -> Vector3:
    var dir = Vector3.ZERO
    
    var virtual_input = virtual_joystick_L.get_input_vector()
    dir.x += virtual_input.x
    dir.z += virtual_input.y
    
    return dir

func get_gamepad_input_direction() -> Vector3:
    var dir = Vector3.ZERO

    dir.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
    dir.z = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
    if dir.length_squared() < 0.1:
        dir = Vector3.ZERO
    
    return dir

func get_input_direction() -> Vector3:
    # キーボードの入力はサイズ1か0で確定
    var key_dir = get_key_input_direction()
    
    var virtual_dir = get_virtual_input_direction()

    # ゲームパッドの入力はサイズ1未満の可能性がある
    var gamepad_dir = get_gamepad_input_direction()

    # 実際に適用される移動用ベクトルはすべての入力方法の和を使用する
    var dir = key_dir + virtual_dir + gamepad_dir

    # すべての入力を足した結果サイズが1を超えたら1に正規化する
    if dir.length_squared() > 1:
        dir = dir.normalized()
    
    return dir.normalized()
