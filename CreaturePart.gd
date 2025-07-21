extends Node3D
class_name CreaturePart

@export var part_name: String = ""
@export var part_type: String = ""
@export var part_stats: Dictionary = {}
@export var part_color: Color = Color.WHITE

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready():
    mesh_instance = $MeshInstance3D
    collision_shape = $CollisionShape3D
    setup_part()

func setup_part():
    # Configura a mesh baseada no tipo da parte
    match part_type:
        "body":
            setup_body_part()
        "leg":
            setup_leg_part()
        "arm":
            setup_arm_part()
        "eye":
            setup_eye_part()
        "mouth":
            setup_mouth_part()
        "weapon":
            setup_weapon_part()

func setup_body_part():
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.5
    sphere_mesh.height = 1.0
    mesh_instance.mesh = sphere_mesh
    
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = 0.5
    collision_shape.shape = sphere_shape

func setup_leg_part():
    var cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 0.1
    cylinder_mesh.bottom_radius = 0.15
    cylinder_mesh.height = 0.8
    mesh_instance.mesh = cylinder_mesh
    
    var cylinder_shape = CylinderShape3D.new()
    cylinder_shape.top_radius = 0.1
    cylinder_shape.bottom_radius = 0.15
    cylinder_shape.height = 0.8
    collision_shape.shape = cylinder_shape

func setup_arm_part():
    var cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 0.08
    cylinder_mesh.bottom_radius = 0.12
    cylinder_mesh.height = 0.6
    mesh_instance.mesh = cylinder_mesh
    
    var cylinder_shape = CylinderShape3D.new()
    cylinder_shape.top_radius = 0.08
    cylinder_shape.bottom_radius = 0.12
    cylinder_shape.height = 0.6
    collision_shape.shape = cylinder_shape

func setup_eye_part():
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.15
    sphere_mesh.height = 0.3
    mesh_instance.mesh = sphere_mesh
    
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = 0.15
    collision_shape.shape = sphere_shape

func setup_mouth_part():
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.2
    sphere_mesh.height = 0.4
    mesh_instance.mesh = sphere_mesh
    
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = 0.2
    collision_shape.shape = sphere_shape

func setup_weapon_part():
    var cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 0.0
    cylinder_mesh.bottom_radius = 0.1
    cylinder_mesh.height = 0.4
    mesh_instance.mesh = cylinder_mesh
    
    var cylinder_shape = CylinderShape3D.new()
    cylinder_shape.top_radius = 0.0
    cylinder_shape.bottom_radius = 0.1
    cylinder_shape.height = 0.4
    collision_shape.shape = cylinder_shape

func apply_material():
    var material = StandardMaterial3D.new()
    material.albedo_color = part_color
    material.roughness = 0.8
    mesh_instance.set_surface_override_material(0, material)

func get_stats():
    return part_stats

func set_part_data(name: String, type: String, stats: Dictionary, color: Color):
    part_name = name
    part_type = type
    part_stats = stats
    part_color = color
    setup_part()
    apply_material()

