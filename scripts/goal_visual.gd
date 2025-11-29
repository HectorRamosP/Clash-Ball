extends Node2D

@export var goal_width: float = 200.0
@export var goal_depth: float = 60.0
@export var post_thickness: float = 10.0
@export var is_left_goal: bool = true

func _draw():
	var color = Color.WHITE

	if is_left_goal:
		# Poste izquierdo (arriba)
		draw_rect(Rect2(0, -goal_width/2, post_thickness, post_thickness), color)

		# Poste izquierdo (abajo)
		draw_rect(Rect2(0, goal_width/2 - post_thickness, post_thickness, post_thickness), color)

		# Línea trasera curva
		var points = PackedVector2Array()
		points.append(Vector2(post_thickness/2, -goal_width/2 + post_thickness/2))

		# Curva hacia adentro
		var segments = 20
		for i in range(segments + 1):
			var t = float(i) / float(segments)
			var y = lerp(-goal_width/2, goal_width/2, t)
			var x_curve = -goal_depth * sin(t * PI)
			points.append(Vector2(x_curve, y))

		points.append(Vector2(post_thickness/2, goal_width/2 - post_thickness/2))

		draw_polyline(points, color, post_thickness/2)
	else:
		# Portería derecha (espejo)
		# Poste derecho (arriba)
		draw_rect(Rect2(-post_thickness, -goal_width/2, post_thickness, post_thickness), color)

		# Poste derecho (abajo)
		draw_rect(Rect2(-post_thickness, goal_width/2 - post_thickness, post_thickness, post_thickness), color)

		# Línea trasera curva
		var points = PackedVector2Array()
		points.append(Vector2(-post_thickness/2, -goal_width/2 + post_thickness/2))

		# Curva hacia adentro
		var segments = 20
		for i in range(segments + 1):
			var t = float(i) / float(segments)
			var y = lerp(-goal_width/2, goal_width/2, t)
			var x_curve = goal_depth * sin(t * PI)
			points.append(Vector2(x_curve, y))

		points.append(Vector2(-post_thickness/2, goal_width/2 - post_thickness/2))

		draw_polyline(points, color, post_thickness/2)
