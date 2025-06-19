extends Control

@onready var base = $Base
@onready var knob = $Knob

var dragging = false
var radius = 100
var input_vector := Vector2.ZERO

func _ready():
    knob.position = base.position + base.size / 2.0 - knob.size / 2.0

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        var pos = base.get_global_mouse_position() - base.global_position
        var center = base.size / 2.0
        var offset = pos - center

        if event is InputEventScreenTouch:
            if event.pressed:
                dragging = true
            else:
                dragging = false
                input_vector = Vector2.ZERO
                knob.position = base.position + center - knob.size / 2.0

        if dragging:
            # raduisより大きかったら大きさraduisのベクトルにする
            if offset.length() > radius:
                offset = offset.normalized() * radius
            
            knob.position = base.position + center + offset - knob.size / 2.0
            input_vector = offset / radius

func get_input_vector() -> Vector2:
    return input_vector
