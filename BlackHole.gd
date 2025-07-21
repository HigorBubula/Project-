extends MeshInstance3D

var material_black_hole

func _ready():
    # Reduz o tamanho do buraco negro
    scale = Vector3(2.0, 2.0, 2.0)
    
    # Cria um material escuro para o buraco negro
    material_black_hole = StandardMaterial3D.new()
    material_black_hole.albedo_color = Color(0.05, 0.05, 0.05, 1.0)
    material_black_hole.emission_enabled = true
    material_black_hole.emission = Color(0.1, 0.0, 0.1, 1.0)
    material_black_hole.metallic = 1.0
    material_black_hole.roughness = 0.0
    set_surface_override_material(0, material_black_hole)
    
    # Material para o horizonte de eventos (anel ao redor)
    var material_event_horizon = StandardMaterial3D.new()
    material_event_horizon.albedo_color = Color(0.2, 0.1, 0.3, 0.8)
    material_event_horizon.emission_enabled = true
    material_event_horizon.emission = Color(0.3, 0.1, 0.5, 1.0)
    material_event_horizon.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $EventHorizon.set_surface_override_material(0, material_event_horizon)

func _process(delta):
    # Rotaciona o buraco negro para dar efeito visual
    rotate_y(deg_to_rad(10) * delta)
    $EventHorizon.rotate_y(deg_to_rad(-15) * delta)

