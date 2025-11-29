extends Node2D

@export var radius: float = 80.0
@export var color: Color = Color(1, 1, 1, 0.3)
@export var line_width: float = 3.0

func _draw():
	# Dibujar círculo central
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, line_width)

	# Dibujar punto central
	draw_circle(Vector2.ZERO, 5.0, color)
