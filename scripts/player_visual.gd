extends Node2D

@export var player_color: Color = Color(0.2, 0.6, 1.0)  # Azul por defecto
@export var radius: float = 25.0
@export var show_class_indicator: bool = true

var parent_player: CharacterBody2D

func _ready():
	parent_player = get_parent()
	if parent_player:
		# Cambiar color según el equipo
		if parent_player.team == 1:
			player_color = Color(0.2, 0.6, 1.0)  # Azul (equipo izquierdo)
		else:
			player_color = Color(1.0, 0.3, 0.2)  # Rojo (equipo derecho)

func _draw():
	# Dibujar cuerpo del jugador (círculo)
	draw_circle(Vector2.ZERO, radius, player_color)

	# Dibujar borde negro
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.BLACK, 2.0)

	# Dibujar indicador de clase en el centro
	if show_class_indicator and parent_player:
		var indicator_color = Color.WHITE
		var indicator_size = 8.0

		# Sprinter = círculo pequeño, Tank = cuadrado
		if parent_player.player_class == GameConfig.PlayerClass.SPRINTER:
			draw_circle(Vector2.ZERO, indicator_size, indicator_color)
		else:  # TANK
			draw_rect(Rect2(-indicator_size, -indicator_size, indicator_size * 2, indicator_size * 2), indicator_color)

func _process(_delta):
	# Redibujar si está tacleando (para efecto visual)
	if parent_player and parent_player.is_tackling:
		queue_redraw()
	elif parent_player and not parent_player.is_tackling:
		queue_redraw()
