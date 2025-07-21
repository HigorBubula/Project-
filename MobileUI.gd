extends CanvasLayer

var player: CharacterBody3D
var virtual_joystick: Control
var jump_button: Button

func _ready():
    setup_mobile_ui()
    print("MobileUI.gd: _ready() chamado.")

func setup_mobile_ui():
    # Carrega e instancia o joystick virtual
    var joystick_scene = preload("res://Scenes/VirtualJoystick.tscn")
    virtual_joystick = joystick_scene.instantiate()
    add_child(virtual_joystick)
    print("MobileUI.gd: Joystick virtual instanciado.")
    
    # Posiciona o joystick no canto inferior esquerdo
    virtual_joystick.position = Vector2(30, get_viewport().size.y - 210)
    
    # Cria botão de pulo
    jump_button = Button.new()
    jump_button.text = "PULAR"
    jump_button.size = Vector2(80, 80)
    jump_button.position = Vector2(get_viewport().size.x - 130, get_viewport().size.y - 170)
    print("MobileUI.gd: Botão de pulo criado.")
    
    # Estiliza o botão
    var style_normal = StyleBoxFlat.new()
    style_normal.bg_color = Color(0.3, 0.3, 0.8, 0.7)
    style_normal.corner_radius_top_left = 40
    style_normal.corner_radius_top_right = 40
    style_normal.corner_radius_bottom_right = 40
    style_normal.corner_radius_bottom_left = 40
    
    var style_pressed = StyleBoxFlat.new()
    style_pressed.bg_color = Color(0.2, 0.2, 0.6, 0.9)
    style_pressed.corner_radius_top_left = 40
    style_pressed.corner_radius_top_right = 40
    style_pressed.corner_radius_bottom_right = 40
    style_pressed.corner_radius_bottom_left = 40
    
    jump_button.add_theme_stylebox_override("normal", style_normal)
    jump_button.add_theme_stylebox_override("pressed", style_pressed)
    
    add_child(jump_button)
    
    # Conecta sinais
    jump_button.pressed.connect(_on_jump_pressed)
    print("MobileUI.gd: Sinais conectados.")

func set_player(new_player: CharacterBody3D):
    player = new_player
    print("MobileUI.gd: Player recebido: ", str(player))
    if virtual_joystick:
        virtual_joystick.stick_moved.connect(player._on_joystick_moved)
        print("MobileUI.gd: Sinal do joystick conectado ao player.")

func _on_jump_pressed():
    if player:
        player.jump()
        print("MobileUI.gd: Botão de pulo pressionado.")

