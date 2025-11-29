extends Area2D

# ===== CONFIGURACIÓN =====
@export var goal_team: int = 1  # 1 = portería izquierda, 2 = portería derecha

# ===== SEÑALES =====
signal goal_scored()

func _ready():
	# Conectar señal de detección
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificar si es la pelota
	if body.name == "Ball":
		print("¡La pelota entró en la portería del equipo " + str(goal_team) + "!")
		goal_scored.emit()
