extends Node3D

@export var camera_distance = 5.0
@export var camera_height = 2.0
@export var rotation_speed = 2.0
@export var zoom_speed = 1.0
@export var min_distance = 2.0
@export var max_distance = 10.0

var target: Node3D
var camera: Camera3D
var current_rotation = 0.0
var current_pitch = -20.0
var is_dragging = false
var last_touch_position = Vector2.ZERO
var touch_count = 0
var initial_distance = 0.0

func _ready():
    # Cria a câmera se não existir
    if not camera:
        camera = Camera3D.new()
        add_child(camera)
    
    update_camera_position()

func set_target(new_target: Node3D):
    target = new_target

func _input(event):
    if event is InputEventScreenTouch:
        handle_touch(event)
    elif event is InputEventScreenDrag:
        handle_drag(event)

func handle_touch(event: InputEventScreenTouch):
    if event.pressed:
        touch_count += 1
        if touch_count == 1:
            is_dragging = true
            last_touch_position = event.position
        elif touch_count == 2:
            # Início do zoom com dois dedos
            is_dragging = false
    else:
        touch_count -= 1
        if touch_count <= 0:
            touch_count = 0
            is_dragging = false

func handle_drag(event: InputEventScreenDrag):
    if is_dragging and touch_count == 1:
        # Rotação da câmera com um dedo
        var delta = event.position - last_touch_position
        current_rotation += delta.x * rotation_speed * 0.01
        current_pitch += delta.y * rotation_speed * 0.01
        current_pitch = clamp(current_pitch, -80, 80)
        
        update_camera_position()
        last_touch_position = event.position

func _process(_delta):
    if target:
        global_position = target.global_position
        update_camera_position()

func update_camera_position():
    if not camera or not target:
        return
    
    # Calcula a posição da câmera baseada na rotação
    var rotation_rad = deg_to_rad(current_rotation)
    var pitch_rad = deg_to_rad(current_pitch)
    
    var camera_offset = Vector3(
        sin(rotation_rad) * cos(pitch_rad) * camera_distance,
        sin(pitch_rad) * camera_distance + camera_height,
        cos(rotation_rad) * cos(pitch_rad) * camera_distance
    )
    
    camera.global_position = target.global_position + camera_offset
    camera.look_at(target.global_position, Vector3.UP)

