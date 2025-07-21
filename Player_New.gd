extends RigidBody3D

var move_speed = 10.0
var jump_force = 15.0
var gravity_bodies = []

# Referências para controles mobile
var mobile_ui: CanvasLayer
var camera_controller: Node3D
var joystick_input = Vector2.ZERO

func _ready():
    # Configura o material do cubo
    var material_cube = StandardMaterial3D.new()
    material_cube.albedo_color = Color(1.0, 0.5, 0.0, 1.0) # Laranja
    $MeshInstance3D.set_surface_override_material(0, material_cube)
    
    # Configura controles mobile
    setup_mobile_controls()

func setup_mobile_controls():
    # Carrega e instancia a UI mobile
    var ui_scene = preload("res://Scenes/MobileUI.tscn")
    mobile_ui = ui_scene.instantiate()
    get_tree().current_scene.add_child(mobile_ui)
    mobile_ui.set_player(self)
    
    # Carrega e instancia o controlador de câmera
    var camera_scene = preload("res://Scenes/TouchCameraController.tscn")
    camera_controller = camera_scene.instantiate()
    get_tree().current_scene.add_child(camera_controller)
    camera_controller.set_target(self)

func _on_joystick_moved(vector: Vector2):
    joystick_input = vector

func _physics_process(delta):
    handle_mobile_input()
    handle_keyboard_input()  # Mantém suporte para teclado
    apply_fake_gravity(delta) # Mantém a gravidade original

func handle_mobile_input():
    if joystick_input != Vector2.ZERO:
        # Converte input 2D do joystick para movimento 3D
        var camera_transform = camera_controller.camera.global_transform if camera_controller and camera_controller.camera else global_transform
        var forward = -camera_transform.basis.z
        var right = camera_transform.basis.x
        
        # Remove componente Y para movimento horizontal
        forward.y = 0
        right.y = 0
        forward = forward.normalized()
        right = right.normalized()
        
        var movement = (forward * joystick_input.y + right * joystick_input.x) * move_speed
        apply_central_impulse(movement * 0.1)

func handle_keyboard_input():
    # Mantém controles de teclado para teste no desktop
    var input_vector = Vector3.ZERO
    
    if Input.is_action_pressed("move_forward"):
        input_vector -= transform.basis.z
    if Input.is_action_pressed("move_backward"):
        input_vector += transform.basis.z
    if Input.is_action_pressed("move_left"):
        input_vector -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        input_vector += transform.basis.x
    
    if input_vector != Vector3.ZERO:
        input_vector = input_vector.normalized() * move_speed
        apply_central_impulse(input_vector * 0.1)
    
    if Input.is_action_just_pressed("jump"):
        apply_central_impulse(Vector3.UP * jump_force)

func apply_fake_gravity(delta):
    # Aplica gravidade fake de todos os planetas próximos
    for gravity_data in gravity_bodies:
        var planet = gravity_data["planet"]
        var strength = gravity_data["strength"]
        
        if is_instance_valid(planet):
            var direction = (planet.global_position - global_position).normalized()
            var distance = global_position.distance_to(planet.global_position)
            var gravity_force = direction * strength * (1.0 / (distance * 0.1 + 1.0))
            apply_central_force(gravity_force)

func apply_gravity(planet, strength):
    # Adiciona um planeta à lista de gravidade
    var gravity_data = {"planet": planet, "strength": strength}
    gravity_bodies.append(gravity_data)

func remove_gravity(planet):
    # Remove um planeta da lista de gravidade
    for i in range(gravity_bodies.size() - 1, -1, -1):
        if gravity_bodies[i]["planet"] == planet:
            gravity_bodies.remove_at(i)
            break


