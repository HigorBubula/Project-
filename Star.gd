extends MeshInstance3D

var black_hole_center = Vector3.ZERO
var orbit_speed = 0.5
var orbit_radius = 100.0
var orbit_angle = 0.0
var star_size = 1.0

func _ready():
    # Define tamanho aleatório da estrela (ainda menor)
    star_size = randf_range(0.05, 0.2) # Reduzindo o range de tamanho para estrelas menores
    scale = Vector3(star_size, star_size, star_size)
    
    # Calcula o raio orbital baseado na posição inicial
    orbit_radius = black_hole_center.distance_to(position)
    orbit_angle = atan2(position.z - black_hole_center.z, position.x - black_hole_center.x)
    
    # Define velocidade orbital (estrelas mais distantes orbitam mais devagar)
    orbit_speed = randf_range(0.01, 0.1) / (orbit_radius * 0.001)
    
    # Cria material para a estrela
    var material_star = StandardMaterial3D.new()
    var star_colors = [
        Color(1.0, 0.4, 0.2, 1.0), # Vermelha
        Color(1.0, 1.0, 0.0, 1.0), # Amarela
        Color(0.6, 0.8, 1.0, 1.0)  # Azul claro
    ]
    material_star.albedo_color = star_colors[randi() % star_colors.size()]
    material_star.emission_enabled = true
    material_star.emission = material_star.albedo_color
    material_star.emission_energy = 2.0
    set_surface_override_material(0, material_star)
    
    # Ajusta a luz da estrela
    $Light.light_color = material_star.albedo_color
    $Light.light_energy = star_size * 1.0
    $Light.omni_range = star_size * 15.0

func set_black_hole_center(center):
    black_hole_center = center

func orbit_black_hole(delta):
    # Animação simples de órbita ao redor do buraco negro
    orbit_angle += orbit_speed * delta
    var new_x = black_hole_center.x + cos(orbit_angle) * orbit_radius
    var new_z = black_hole_center.z + sin(orbit_angle) * orbit_radius
    position = Vector3(new_x, position.y, new_z)


