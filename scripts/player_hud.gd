extends Control

# ===== REFERENCIAS =====
@onready var stamina_bar = $StaminaBar
@onready var stamina_bg = $StaminaBG
@onready var tackles_label = $TacklesLabel
@onready var class_label = $ClassLabel

# ===== CONFIGURACIÓN =====
@export var player_reference: CharacterBody2D
@export var hud_color: Color = Color(0.2, 0.6, 1.0)  # Azul por defecto

func _ready():
	if player_reference:
		connect_to_player()
		update_class_label()
		update_hud_color()

func connect_to_player():
	# Conectar señales del jugador
	player_reference.stamina_changed.connect(_on_stamina_changed)
	player_reference.tackles_changed.connect(_on_tackles_changed)

	# Inicializar valores
	_on_stamina_changed(player_reference.stamina)
	_on_tackles_changed(player_reference.remaining_tackles)

func update_class_label():
	var player_class_name = GameConfig.get_class_stats(player_reference.player_class).name
	class_label.text = player_class_name

func update_hud_color():
	# Color según el equipo
	if player_reference.team == 1:
		hud_color = Color(0.2, 0.6, 1.0)  # Azul
	else:
		hud_color = Color(1.0, 0.3, 0.2)  # Rojo

	# Aplicar color a los elementos
	stamina_bar.color = hud_color

func _on_stamina_changed(new_stamina: float):
	# Actualizar barra de estamina
	var stamina_percent = new_stamina / GameConfig.MAX_STAMINA
	stamina_bar.size.x = stamina_bg.size.x * stamina_percent

func _on_tackles_changed(remaining: int):
	# Actualizar contador de tacleos
	tackles_label.text = "Tackles: " + str(remaining)
