extends Node2D

@export var goal_width: float = 200.0
@export var goal_depth: float = 80.0
@export var post_thickness: float = 12.0
@export var is_left_goal: bool = true

func _draw():
	var post_color = Color.WHITE
	var net_color = Color(0.8, 0.8, 0.8, 0.5)
	var back_color = Color(0.2, 0.2, 0.2, 0.3)

	if is_left_goal:
		# FONDO OSCURO (para ver la profundidad)
		var back_points = PackedVector2Array()
		back_points.append(Vector2(0, -goal_width/2))
		back_points.append(Vector2(-goal_depth, -goal_width/2 + 20))
		back_points.append(Vector2(-goal_depth, goal_width/2 - 20))
		back_points.append(Vector2(0, goal_width/2))
		draw_colored_polygon(back_points, back_color)

		# RED (líneas diagonales)
		for i in range(5):
			var y_start = lerp(-goal_width/2, goal_width/2, float(i) / 4.0)
			draw_line(Vector2(0, y_start), Vector2(-goal_depth, y_start), net_color, 1.5)

		for i in range(4):
			var x_pos = -goal_depth * (float(i) / 3.0)
			draw_line(Vector2(x_pos, -goal_width/2), Vector2(x_pos, goal_width/2), net_color, 1.5)

		# POSTES BLANCOS
		# Poste superior
		draw_rect(Rect2(-5, -goal_width/2 - post_thickness/2, post_thickness, post_thickness), post_color)

		# Poste inferior
		draw_rect(Rect2(-5, goal_width/2 - post_thickness/2, post_thickness, post_thickness), post_color)

		# Línea de la portería (frente)
		draw_line(Vector2(0, -goal_width/2), Vector2(0, goal_width/2), post_color, 4.0)

	else:
		# PORTERÍA DERECHA (espejo)
		# FONDO OSCURO
		var back_points = PackedVector2Array()
		back_points.append(Vector2(0, -goal_width/2))
		back_points.append(Vector2(goal_depth, -goal_width/2 + 20))
		back_points.append(Vector2(goal_depth, goal_width/2 - 20))
		back_points.append(Vector2(0, goal_width/2))
		draw_colored_polygon(back_points, back_color)

		# RED
		for i in range(5):
			var y_start = lerp(-goal_width/2, goal_width/2, float(i) / 4.0)
			draw_line(Vector2(0, y_start), Vector2(goal_depth, y_start), net_color, 1.5)

		for i in range(4):
			var x_pos = goal_depth * (float(i) / 3.0)
			draw_line(Vector2(x_pos, -goal_width/2), Vector2(x_pos, goal_width/2), net_color, 1.5)

		# POSTES BLANCOS
		# Poste superior
		draw_rect(Rect2(-7, -goal_width/2 - post_thickness/2, post_thickness, post_thickness), post_color)

		# Poste inferior
		draw_rect(Rect2(-7, goal_width/2 - post_thickness/2, post_thickness, post_thickness), post_color)

		# Línea de la portería (frente)
		draw_line(Vector2(0, -goal_width/2), Vector2(0, goal_width/2), post_color, 4.0)
