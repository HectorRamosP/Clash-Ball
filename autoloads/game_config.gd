extends Node

# ===== ENUMERACIONES =====
enum PlayerClass {
	SPRINTER,
	TANK
}

enum PowerType {
	NONE,
	SUPER_SPEED,      # Supervelocidad
	SUPER_STRENGTH,   # Fuerza aumentada
	MAGNETO,          # Pelota pegada
	UNLIMITED_TACKLES # Tacleos ilimitados
}

enum GameMode {
	ONE_VS_ONE,
	TWO_VS_TWO
}

# ===== CONFIGURACIÓN DE CLASES =====
const CLASS_STATS = {
	PlayerClass.SPRINTER: {
		"name": "Sprinter",
		"speed": 400.0,
		"push_force": 300.0,
		"initial_tackles": 2
	},
	PlayerClass.TANK: {
		"name": "Tank",
		"speed": 250.0,
		"push_force": 600.0,
		"initial_tackles": 4
	}
}

# ===== CONFIGURACIÓN DE PODERES =====
const POWER_DURATION = {
	PowerType.SUPER_SPEED: 5.0,
	PowerType.SUPER_STRENGTH: 5.0,
	PowerType.MAGNETO: 8.0,
	PowerType.UNLIMITED_TACKLES: 3.0
}

const POWER_NAMES = {
	PowerType.NONE: "Ninguno",
	PowerType.SUPER_SPEED: "Supervelocidad",
	PowerType.SUPER_STRENGTH: "Superfuerza",
	PowerType.MAGNETO: "Magneto",
	PowerType.UNLIMITED_TACKLES: "Tacleos Ilimitados"
}

# ===== CONFIGURACIÓN GENERAL DEL JUEGO =====
const MAX_STAMINA = 100.0
const STAMINA_DRAIN_RATE = 20.0  # Por segundo al correr
const STAMINA_REGEN_RATE = 15.0  # Por segundo al no correr
const TACKLE_COOLDOWN = 2.0      # Segundos entre tacleos
const TACKLE_FORCE = 800.0       # Fuerza del tacleo
const TACKLE_DURATION = 0.3      # Duración del impulso del tacleo

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
signal power_granted(player_id: String, power: PowerType)

# ===== FUNCIONES AUXILIARES =====
func get_class_stats(player_class: PlayerClass) -> Dictionary:
	return CLASS_STATS[player_class]

func get_random_power() -> PowerType:
	var powers = [
		PowerType.SUPER_SPEED,
		PowerType.SUPER_STRENGTH,
		PowerType.MAGNETO,
		PowerType.UNLIMITED_TACKLES
	]
	return powers[randi() % powers.size()]

func get_power_name(power: PowerType) -> String:
	return POWER_NAMES[power]

func get_power_duration(power: PowerType) -> float:
	if power in POWER_DURATION:
		return POWER_DURATION[power]
	return 0.0

func reset_game_settings():
	current_game_mode = GameMode.ONE_VS_ONE
	player_classes = {
		"player1": PlayerClass.SPRINTER,
		"player2": PlayerClass.TANK,
		"player3": PlayerClass.SPRINTER,
		"player4": PlayerClass.TANK
	}
