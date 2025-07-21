extends MeshInstance3D

var star_center = Vector3.ZERO
var orbit_speed = 1.0
var orbit_radius = 10.0
var orbit_angle = 0.0
var planet_size = 1.0
var gravity_strength = 10.0
var is_rocky = true

func _ready():
    # Define tamanho aleatório do planeta (muito menor)
    planet_size = randf_range(0.1, 0.8)
    scale = Vector3(planet_size, planet_size, planet_size)
    
    # Calcula o raio orbital baseado na posição inicial
    if star_center != Vector3.ZERO:
        orbit_radius = star_center.distance_to(position)
        orbit_angle = atan2(position.z - star_center.z, position.x - star_center.x)
    
    # Define se é rochoso ou gasoso baseado na distância da estrela
    is_rocky = orbit_radius < 15.0
    
    # Define velocidade orbital
    orbit_speed = randf_range(0.5, 2.0) / (orbit_radius * 0.1)
    
    # Cria material para o planeta com as cores especificadas
    var material_planet = StandardMaterial3D.new()
    var planet_colors = [
        Color(0.2, 0.8, 0.2, 1.0), # Verde
        Color(0.6, 0.6, 0.6, 1.0), # Cinza
        Color(0.1, 0.2, 0.6, 1.0), # Azul escuro
        Color(0.8, 0.2, 0.2, 1.0)  # Vermelho
    ]
    material_planet.albedo_color = planet_colors[randi() % planet_colors.size()]
    material_planet.roughness = 0.8
    set_surface_override_material(0, material_planet)
    
    # Configura área de gravidade
    setup_gravity_area()

func setup_gravity_area():
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = planet_size * 2.0 # Área de influência da gravidade menor
    $GravityArea/CollisionShape3D.shape = sphere_shape
    
    # Conecta sinais para detectar entrada e saída de objetos
    $GravityArea.body_entered.connect(_on_body_entered)
    $GravityArea.body_exited.connect(_on_body_exited)

func set_star_center(center):
    star_center = center

func set_gravity_strength(strength):
    gravity_strength = strength

func orbit_star(delta):
    if star_center != Vector3.ZERO:
        # Animação simples de órbita ao redor da estrela
        orbit_angle += orbit_speed * delta
        var new_x = star_center.x + cos(orbit_angle) * orbit_radius
        var new_z = star_center.z + sin(orbit_angle) * orbit_radius
        position = Vector3(new_x, position.y, new_z)

func orbit_planet(delta):
    # Para luas orbitando planetas
    var parent_planet = get_parent()
    if parent_planet and parent_planet.has_method("get_global_transform"):
        orbit_angle += orbit_speed * delta
        var new_x = cos(orbit_angle) * orbit_radius
        var new_z = sin(orbit_angle) * orbit_radius
        position = Vector3(new_x, position.y, new_z)

func _on_body_entered(body):
    # Aplica gravidade fake ao cubo (ou qualquer RigidBody3D)
    if body.has_method("apply_gravity"):
        body.apply_gravity(self, gravity_strength)

func _on_body_exited(body):
    # Remove gravidade fake
    if body.has_method("remove_gravity"):
        body.remove_gravity(self)

