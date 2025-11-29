extends Node2D

# ===== REFERENCIAS A NODOS =====
@onready var ball = $Ball
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var player3 = $Player3 if has_node("Player3") else null
@onready var player4 = $Player4 if has_node("Player4") else null
@onready var goal_left = $GoalLeft
@onready var goal_right = $GoalRight

# UI
@onready var player1_hud = $UI/Player1HUD
@onready var player2_hud = $UI/Player2HUD
@onready var scoreboard = $UI/Scoreboard

# ===== PUNTUACIÓN =====
var score_team1: int = 0
var score_team2: int = 0
var max_score: int = 5  # Goles para ganar

# ===== POSICIONES INICIALES =====
var field_width: float = 1280.0
var field_height: float = 720.0
var ball_start_pos: Vector2
var player_positions: Dictionary = {}

# ===== SEÑALES =====
signal score_updated(team1_score: int, team2_score: int)
signal match_ended(winning_team: int)

func _ready():
	setup_field()
	setup_positions()
	reset_positions()
	connect_signals()
	setup_ui()

func setup_field():
	# Configurar tamaño de la ventana
	get_viewport().size = Vector2i(field_width, field_height)

	# Calcular posiciones iniciales
	ball_start_pos = Vector2(field_width / 2, field_height / 2)

func setup_positions():
	# Posiciones iniciales para 1v1
	player_positions["player1"] = Vector2(field_width * 0.25, field_height / 2)
	player_positions["player2"] = Vector2(field_width * 0.75, field_height / 2)

	# Posiciones para 2v2
	player_positions["player3"] = Vector2(field_width * 0.35, field_height / 2)
	player_positions["player4"] = Vector2(field_width * 0.65, field_height / 2)

func connect_signals():
	# Conectar señales de goles
	if goal_left:
		goal_left.goal_scored.connect(_on_goal_scored.bind(2))  # Equipo 2 anotó
	if goal_right:
		goal_right.goal_scored.connect(_on_goal_scored.bind(1))  # Equipo 1 anotó

	# Dar referencia de la pelota a los jugadores
	if player1:
		player1.set_ball_reference(ball)
	if player2:
		player2.set_ball_reference(ball)
	if player3:
		player3.set_ball_reference(ball)
	if player4:
		player4.set_ball_reference(ball)

	# Conectar señal de actualización de marcador
	score_updated.connect(_on_score_updated)

func setup_ui():
	# Configurar HUD de jugadores
	if player1_hud and player1:
		player1_hud.player_reference = player1
	if player2_hud and player2:
		player2_hud.player_reference = player2

func _on_score_updated(team1: int, team2: int):
	# Actualizar el marcador visual
	if scoreboard:
		scoreboard.update_score(team1, team2)

func reset_positions():
	# Resetear pelota
	if ball:
		ball.reset_position(ball_start_pos)

	# Resetear jugadores
	if player1:
		player1.global_position = player_positions["player1"]
		player1.reset_for_goal()
	if player2:
		player2.global_position = player_positions["player2"]
		player2.reset_for_goal()
	if player3:
		player3.global_position = player_positions["player3"]
		player3.reset_for_goal()
	if player4:
		player4.global_position = player_positions["player4"]
		player4.reset_for_goal()

func _on_goal_scored(scoring_team: int):
	print("¡GOL! Equipo " + str(scoring_team) + " anotó!")

	# Actualizar puntuación
	if scoring_team == 1:
		score_team1 += 1
	else:
		score_team2 += 1

	score_updated.emit(score_team1, score_team2)

	# Verificar si alguien ganó
	if score_team1 >= max_score:
		match_ended.emit(1)
		print("¡Equipo 1 (Azul) GANÓ!")
	elif score_team2 >= max_score:
		match_ended.emit(2)
		print("¡Equipo 2 (Rojo) GANÓ!")
	else:
		# Reiniciar posiciones después de un pequeño delay
		await get_tree().create_timer(2.0).timeout
		reset_positions()
