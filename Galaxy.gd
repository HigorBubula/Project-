extends Node3D

var BlackHole = preload("res://Scenes/BlackHole.tscn")
var Star = preload("res://Scenes/Star.tscn")
var Planet = preload("res://Scenes/Planet.tscn")
var Player = preload("res://Scenes/Player.tscn")

func _ready():
    print("Galaxy script iniciado!")
    
    # Instancia o buraco negro
    var black_hole_instance = BlackHole.instantiate()
    $BlackHole.add_child(black_hole_instance)
    print("Buraco negro criado!")

    # Gera estrelas em um padrão espiral mais realista
    var num_arms = 4 # Número de braços espirais
    var arm_tightness = 1.2 # Quão apertada a espiral é (maior valor = mais apertada)
    var max_radius = 800.0 # Raio máximo da galáxia (aumentado)
    var stars_per_arm = 200 # Estrelas por braço (total de 800 estrelas)
    var arm_offset = 0.3 # Deslocamento angular para cada braço (aumentado)

    for arm_index in range(num_arms):
        for i in range(stars_per_arm):
            var star_instance = Star.instantiate()
            $Stars.add_child(star_instance)

            var distance = pow(float(i) / stars_per_arm, 1.2) * max_radius # Distribuição mais espalhada
            var angle = (float(i) / stars_per_arm) * PI * 2 * arm_tightness + (arm_index * PI * 2 / num_arms) + (randf() * arm_offset - arm_offset / 2.0) # Adiciona variação angular

            var x = cos(angle) * distance
            var z = sin(angle) * distance
            var y = randf_range(-distance * 0.01, distance * 0.01) # Dispersão vertical ainda menor

            star_instance.position = Vector3(x, y, z)
            star_instance.set_black_hole_center($BlackHole.global_position)
    
    print("Estrelas criadas: ", $Stars.get_child_count())

    var closest_planet = null
    var min_distance_to_black_hole = INF

    # Gera planetas para algumas estrelas (exemplo)
    for star_node in $Stars.get_children():
        if randf() < 0.2: # 20% de chance de ter planetas (reduzido para melhor performance)
            var num_planets = randi() % 3 + 1 # 1 a 3 planetas (reduzido)
            var current_orbital_radius = 20.0 # Raio inicial para o primeiro planeta
            for j in range(num_planets):
                var planet_instance = Planet.instantiate()
                star_node.add_child(planet_instance)
                # Posiciona os planetas em relação à estrela com espaçamento
                var planet_angle = randf() * PI * 2
                var planet_radius = current_orbital_radius + randf_range(5, 15) # Aumenta o raio para cada planeta
                planet_instance.position = Vector3(cos(planet_angle) * planet_radius, randf_range(-0.5, 0.5), sin(planet_angle) * planet_radius)
                planet_instance.set_star_center(star_node.global_position)
                planet_instance.set_gravity_strength(randf_range(0.1, 0.5)) # Gravidade fake menor

                # Gera luas para os planetas (reduzido)
                var num_moons = 0
                if planet_radius < 50: # Planetas rochosos (mais perto)
                    num_moons = randi() % 2 # 0 a 1 lua
                else: # Planetas gasosos (mais longe)
                    num_moons = randi() % 3 # 0 a 2 luas
                
                var current_moon_orbital_radius = 2.0 # Raio inicial para a primeira lua
                for k in range(num_moons):
                    var moon_instance = Planet.instantiate() # Usando a mesma cena Planet para luas por simplicidade
                    planet_instance.add_child(moon_instance)
                    var moon_angle = randf() * PI * 2
                    var moon_radius = current_moon_orbital_radius + randf_range(0.5, 1.5) # Aumenta o raio para cada lua
                    moon_instance.position = Vector3(cos(moon_angle) * moon_radius, randf_range(-0.1, 0.1), sin(moon_angle) * moon_radius)
                    moon_instance.set_gravity_strength(randf_range(0.01, 0.1)) # Gravidade fake para luas
                    current_moon_orbital_radius = moon_radius # Atualiza o raio para a próxima lua
                current_orbital_radius = planet_radius # Atualiza o raio para o próximo planeta

                # Verifica se este é o planeta mais próximo do buraco negro
                var distance_to_black_hole = planet_instance.global_position.distance_to($BlackHole.global_position)
                if distance_to_black_hole < min_distance_to_black_hole:
                    min_distance_to_black_hole = distance_to_black_hole
                    closest_planet = planet_instance

    print("Galáxia gerada com sucesso!")

    # Instancia o jogador no planeta mais próximo do buraco negro
    if closest_planet:
        var player_instance = Player.instantiate()
        closest_planet.add_child(player_instance)
        player_instance.global_position = closest_planet.global_position + Vector3(0, closest_planet.scale.y * 0.5 + 1.0, 0) # Posiciona acima da superfície
        print("Jogador instanciado no planeta mais próximo do buraco negro!")
    else:
        print("Nenhum planeta encontrado para instanciar o jogador.")

func _process(delta):
    # Animação de rotação para o buraco negro (visual)
    $BlackHole.rotate_y(deg_to_rad(5) * delta)

    # Animação de órbita para as estrelas (simples, sem física real)
    for star_node in $Stars.get_children():
        if star_node.has_method("orbit_black_hole"):
            star_node.orbit_black_hole(delta)

    # Animação de órbita para os planetas e luas
    for star_node in $Stars.get_children():
        for planet_node in star_node.get_children():
            if planet_node.has_method("orbit_star"):
                planet_node.orbit_star(delta)
            for moon_node in planet_node.get_children():
                if moon_node.has_method("orbit_planet"):
                    moon_node.orbit_planet(delta)


