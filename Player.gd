extends CharacterBody3D

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
    # Aplica gravidade fake de todos os planetas próximos
    apply_fake_gravity(delta)

    # Movimento baseado no joystick
    handle_mobile_input()
    
    # Movimento do CharacterBody3D
    move_and_slide()

func handle_mobile_input():
    var input_dir = Vector2.ZERO
    
    # Input do joystick mobile
    if joystick_input != Vector2.ZERO:
        input_dir = joystick_input
    
    # Converte input 2D para movimento 3D baseado na câmera
    if input_dir != Vector2.ZERO:
        var camera_transform = camera_controller.camera.global_transform if camera_controller and camera_controller.camera else global_transform
        var forward = -camera_transform.basis.z
        var right = camera_transform.basis.x
        
        # Remove componente Y para movimento horizontal
        forward.y = 0
        right.y = 0
        forward = forward.normalized()
        right = right.normalized()
        
        var direction = (forward * input_dir.y + right * input_dir.x).normalized()
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)

func jump():
    if is_on_floor():
        velocity.y = jump_force

func apply_fake_gravity(delta):
    # Aplica gravidade fake de todos os planetas próximos
    var total_gravity_force = Vector3.ZERO
    for gravity_data in gravity_bodies:
        var planet = gravity_data["planet"]
        var strength = gravity_data["strength"]
        
        if is_instance_valid(planet):
            var direction = (planet.global_position - global_position).normalized()
            var distance = global_position.distance_to(planet.global_position)
            var gravity_force = direction * strength * (1.0 / (distance * 0.1 + 1.0))
            total_gravity_force += gravity_force

    # Aplica a força gravitacional acumulada à velocidade do CharacterBody3D
    velocity += total_gravity_force * delta

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

func get_camera_transform() -> Transform3D:
    return global_transform


