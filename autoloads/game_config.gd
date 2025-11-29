extends Node

# ===== ENUMERACIONES =====
enum PlayerClass {
	SPRINTER,
	TANK
}

enum GameMode {
	ONE_VS_ONE,
	TWO_VS_TWO
}

# ===== CONFIGURACIÓN DE CLASES =====
const CLASS_STATS = {
	PlayerClass.SPRINTER: {
		"name": "Sprinter",
		"speed": 320.0,  # Reducido de 400 para mejor control
		"push_force": 350.0,  # Aumentado un poco
		"initial_tackles": 5
	},
	PlayerClass.TANK: {
		"name": "Tank",
		"speed": 220.0,  # Reducido un poco para balancear
		"push_force": 650.0,  # Aumentado para mayor diferencia
		"initial_tackles": 10
	}
}

# ===== CONFIGURACIÓN GENERAL DEL JUEGO =====
const MAX_STAMINA = 100.0
const STAMINA_DRAIN_RATE = 20.0  # Por segundo al correr
const STAMINA_REGEN_RATE = 15.0  # Por segundo al no correr
const TACKLE_COOLDOWN = 1.5      # Reducido de 2.0 para más acción
const TACKLE_FORCE = 1200.0      # Aumentado de 800 para más impacto
const TACKLE_DURATION = 0.4      # Aumentado de 0.3 para más distancia
const TACKLE_PUSH_MULTIPLIER = 8.0  # Multiplicador para empujar rivales

# ===== CONFIGURACIÓN DE FÍSICA =====
const BALL_FRICTION = 0.98       # Fricción de la pelota (0-1)
const BALL_BOUNCE = 0.7          # Rebote de la pelota (0-1)
const PLAYER_FRICTION = 0.95     # Fricción del jugador

# ===== CONFIGURACIÓN DEL PARTIDO =====
var current_game_mode: GameMode = GameMode.ONE_VS_ONE
var player_classes = {
	"player1": PlayerClass.SPRINTER,
	"player2": PlayerClass.TANK,
	"player3": PlayerClass.SPRINTER,  # Para 2v2
	"player4": PlayerClass.TANK       # Para 2v2
}

# Señales para comunicación entre escenas
signal goal_scored(team: int)

# ===== FUNCIONES AUXILIARES =====
func get_class_stats(player_class: PlayerClass) -> Dictionary:
	return CLASS_STATS[player_class]

func reset_game_settings():
	current_game_mode = GameMode.ONE_VS_ONE
	player_classes = {
		"player1": PlayerClass.SPRINTER,
		"player2": PlayerClass.TANK,
		"player3": PlayerClass.SPRINTER,
		"player4": PlayerClass.TANK
	}
