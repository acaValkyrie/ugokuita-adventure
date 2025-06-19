extends Camera3D

var character : CharacterBody3D

var theta_width: float = 0.0
var theta_height_max: float = PI*2/5
var theta_height_min: float = PI/8
var theta_height: float = theta_height_min
var distance: float = 3.0
var virtual_joystick_R

func _ready():
    # ルートノードからCharacterBody3Dを探す
    character = get_parent().get_node("CharacterBody3D")
    virtual_joystick_R = get_parent().get_node("GUI/VBoxContainer/HBoxContainer/JoyStick_R")

func _physics_process(_delta):
    if not character: return

    look_at(character.global_transform.origin, Vector3.UP)
    
    var gamepad_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
    var gamepad_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    
    var input_gamepad = Vector2(gamepad_x, gamepad_y)
    
    var input_virtual = virtual_joystick_R.get_input_vector()
    
    # キーボードの十字キー入力を取得
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") + input_gamepad + input_virtual
    
    var look_sensitivity_width = 0.1
    var look_sensitivity_height = 0.05
    if input.length_squared() > 0.01:
        theta_height += input.y * look_sensitivity_height
        if theta_height > theta_height_max:
            theta_height = theta_height_max
        elif theta_height < theta_height_min:
            theta_height = theta_height_min
        theta_width -= input.x * look_sensitivity_width
    
    var camera_relative_position = Vector3(
        distance * cos(theta_height) * sin(theta_width),
        distance * sin(theta_height),
        distance * cos(theta_height) * cos(theta_width)
    )
    global_transform.origin = character.global_transform.origin + camera_relative_position
    

    if character.global_transform.origin.y < character.fall_stop_height:
        # カメラの位置をキャラクターの位置に合わせる
        global_transform.origin = character.global_transform.origin + Vector3(0, 0.75, -1.5)

# func _process(_delta):
