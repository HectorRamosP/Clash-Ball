extends Node2D

@export var ball_color: Color = Color(1.0, 1.0, 1.0)  # Blanco
@export var radius: float = 15.0

func _draw():
	# Dibujar pelota (círculo blanco)
	draw_circle(Vector2.ZERO, radius, ball_color)

	# Dibujar borde negro
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.BLACK, 2.0)

	# Dibujar patrón de pelota (líneas)
	draw_line(Vector2(-radius, 0), Vector2(radius, 0), Color.BLACK, 1.5)
	draw_line(Vector2(0, -radius), Vector2(0, radius), Color.BLACK, 1.5)
