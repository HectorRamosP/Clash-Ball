extends Area2D

# ===== CONFIGURACIÓN =====
@export var goal_team: int = 1  # 1 = portería izquierda, 2 = portería derecha

# ===== SEÑALES =====
signal goal_scored()

@onready var visual = $Visual
@onready var goal_area = $GoalArea

func _ready():
	# Conectar señal de detección
	body_entered.connect(_on_body_entered)

	# Configurar visual según el equipo
	if visual:
		visual.is_left_goal = (goal_team == 1)

	# Mover el área de detección hacia el INTERIOR de la portería
	if goal_area:
		if goal_team == 1:  # Portería izquierda
			goal_area.position.x = -30  # Mover hacia la izquierda (interior)
		else:  # Portería derecha
			goal_area.position.x = 30  # Mover hacia la derecha (interior)

func _on_body_entered(body):
	# Verificar si es la pelota
	if body.name == "Ball":
		print("¡La pelota entró en la portería del equipo " + str(goal_team) + "!")
		goal_scored.emit()
