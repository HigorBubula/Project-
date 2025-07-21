extends Control

@onready var knob = $Knob
@onready var background = $Background

var knob_radius = 75.0 # Aumentado de 50.0 para 75.0
var is_pressed = false
var center_point = Vector2.ZERO
var knob_vector = Vector2.ZERO

signal stick_moved(vector: Vector2)

func _ready():
    center_point = size / 2
    knob.position = center_point - knob.size / 2
    background.position = center_point - background.size / 2

func _gui_input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            is_pressed = true
            update_knob_position(event.position)
        else:
            is_pressed = false
            reset_knob()
    elif event is InputEventScreenDrag and is_pressed:
        update_knob_position(event.position)

func update_knob_position(touch_position: Vector2):
    var direction = touch_position - center_point
    var distance = direction.length()
    
    if distance <= knob_radius:
        knob.position = touch_position - knob.size / 2
        knob_vector = direction / knob_radius
    else:
        var clamped_direction = direction.normalized() * knob_radius
        knob.position = center_point + clamped_direction - knob.size / 2
        knob_vector = clamped_direction / knob_radius
    
    stick_moved.emit(knob_vector)

func reset_knob():
    knob.position = center_point - knob.size / 2
    knob_vector = Vector2.ZERO
    stick_moved.emit(knob_vector)

func get_vector() -> Vector2:
    return knob_vector

