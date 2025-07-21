extends Control

var current_creature_parts = []
var available_parts = []
var creature_preview_node

func _ready():
    setup_available_parts()
    setup_ui()
    creature_preview_node = $Panel/VBoxContainer/HBoxContainer/ViewportContainer/SubViewport/CreaturePreview
    
    # Conecta os botões
    $Panel/VBoxContainer/HBoxContainer3/SaveButton.pressed.connect(_on_save_button_pressed)
    $Panel/VBoxContainer/HBoxContainer3/LoadButton.pressed.connect(_on_load_button_pressed)

func setup_available_parts():
    # Define as partes disponíveis para a criatura
    available_parts = [
        {
            "name": "Corpo Base",
            "type": "body",
            "mesh": "sphere",
            "color": Color.WHITE,
            "stats": {"health": 10, "speed": 0}
        },
        {
            "name": "Perna Básica",
            "type": "leg",
            "mesh": "cylinder",
            "color": Color.BROWN,
            "stats": {"health": 2, "speed": 5}
        },
        {
            "name": "Braço Básico",
            "type": "arm",
            "mesh": "cylinder",
            "color": Color.BROWN,
            "stats": {"health": 1, "attack": 3}
        },
        {
            "name": "Olho Simples",
            "type": "eye",
            "mesh": "sphere",
            "color": Color.BLUE,
            "stats": {"health": 1, "sight": 5}
        },
        {
            "name": "Boca Pequena",
            "type": "mouth",
            "mesh": "sphere",
            "color": Color.RED,
            "stats": {"health": 1, "bite": 2}
        },
        {
            "name": "Espinho",
            "type": "weapon",
            "mesh": "cone",
            "color": Color.GRAY,
            "stats": {"health": 1, "attack": 8}
        }
    ]

func setup_ui():
    var parts_grid = $Panel/VBoxContainer/HBoxContainer2/PartsList/ScrollContainer/GridContainer
    
    # Adiciona botões para cada parte disponível
    for part in available_parts:
        var button = Button.new()
        button.text = part.name
        button.pressed.connect(_on_part_button_pressed.bind(part))
        parts_grid.add_child(button)

func _on_part_button_pressed(part):
    # Adiciona a parte à criatura atual
    add_part_to_creature(part)

func add_part_to_creature(part):
    current_creature_parts.append(part.duplicate())
    update_creature_preview()
    update_current_parts_ui()

func update_creature_preview():
    # Limpa a preview atual
    for child in creature_preview_node.get_children():
        if child.name != "Camera3D" and child.name != "DirectionalLight3D":
            child.queue_free()
    
    # Cria a nova preview da criatura
    var creature_root = Node3D.new()
    creature_root.name = "Creature"
    creature_preview_node.add_child(creature_root)
    
    for i in range(current_creature_parts.size()):
        var part = current_creature_parts[i]
        var part_node = create_part_mesh(part)
        part_node.name = part.name + "_" + str(i)
        
        # Posiciona as partes de forma básica
        match part.type:
            "body":
                part_node.position = Vector3.ZERO
            "leg":
                var leg_count = count_parts_of_type("leg")
                part_node.position = Vector3(
                    (i % 2) * 2 - 1,  # Alterna entre -1 e 1 para esquerda/direita
                    -1,
                    0
                )
            "arm":
                var arm_count = count_parts_of_type("arm")
                part_node.position = Vector3(
                    (i % 2) * 2 - 1,  # Alterna entre -1 e 1 para esquerda/direita
                    0.5,
                    0
                )
            "eye":
                part_node.position = Vector3(0, 0.5, 0.8)
            "mouth":
                part_node.position = Vector3(0, 0, 1)
            "weapon":
                part_node.position = Vector3(0, 1, 0)
        
        creature_root.add_child(part_node)

func create_part_mesh(part):
    var mesh_instance = MeshInstance3D.new()
    
    # Cria a mesh baseada no tipo
    match part.mesh:
        "sphere":
            mesh_instance.mesh = SphereMesh.new()
            (mesh_instance.mesh as SphereMesh).radius = 0.3
        "cylinder":
            mesh_instance.mesh = CylinderMesh.new()
            (mesh_instance.mesh as CylinderMesh).top_radius = 0.1
            (mesh_instance.mesh as CylinderMesh).bottom_radius = 0.1
            (mesh_instance.mesh as CylinderMesh).height = 0.5
        "cone":
            mesh_instance.mesh = CylinderMesh.new()
            (mesh_instance.mesh as CylinderMesh).top_radius = 0.0
            (mesh_instance.mesh as CylinderMesh).bottom_radius = 0.1
            (mesh_instance.mesh as CylinderMesh).height = 0.3
    
    # Aplica material colorido
    var material = StandardMaterial3D.new()
    material.albedo_color = part.color
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

func count_parts_of_type(type):
    var count = 0
    for part in current_creature_parts:
        if part.type == type:
            count += 1
    return count

func update_current_parts_ui():
    var parts_container = $Panel/VBoxContainer/HBoxContainer2/CurrentCreatureParts/ScrollContainer/VBoxContainer
    
    # Limpa a lista atual
    for child in parts_container.get_children():
        child.queue_free()
    
    # Adiciona cada parte atual
    for i in range(current_creature_parts.size()):
        var part = current_creature_parts[i]
        var hbox = HBoxContainer.new()
        
        var label = Label.new()
        label.text = part.name
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
        var remove_button = Button.new()
        remove_button.text = "Remover"
        remove_button.pressed.connect(_on_remove_part_pressed.bind(i))
        
        hbox.add_child(label)
        hbox.add_child(remove_button)
        parts_container.add_child(hbox)

func _on_remove_part_pressed(index):
    if index < current_creature_parts.size():
        current_creature_parts.remove_at(index)
        update_creature_preview()
        update_current_parts_ui()

func calculate_creature_stats():
    var stats = {
        "health": 0,
        "speed": 0,
        "attack": 0,
        "sight": 0,
        "bite": 0
    }
    
    for part in current_creature_parts:
        for stat_name in part.stats:
            if stat_name in stats:
                stats[stat_name] += part.stats[stat_name]
    
    return stats

func _on_save_button_pressed():
    var creature_data = {
        "parts": current_creature_parts,
        "stats": calculate_creature_stats()
    }
    
    var file = FileAccess.open("user://saved_creature.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(creature_data))
        file.close()
        print("Criatura salva!")

func _on_load_button_pressed():
    var file = FileAccess.open("user://saved_creature.json", FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var parse_result = json.parse(json_string)
        
        if parse_result == OK:
            var creature_data = json.data
            current_creature_parts = creature_data.parts
            update_creature_preview()
            update_current_parts_ui()
            print("Criatura carregada!")
        else:
            print("Erro ao carregar criatura!")
    else:
        print("Arquivo de criatura não encontrado!")

