extends CharacterBody2D

# ===== CONFIGURACIÓN =====
@export var max_speed: float = 1000.0
@export var friction: float = 0.98
@export var bounce_factor: float = 0.7

# ===== ESTADO =====
var last_hit_by: CharacterBody2D = null
var last_hit_team: int = 0

# ===== SEÑALES =====
signal ball_hit(player: CharacterBody2D)

func _ready():
	friction = GameConfig.BALL_FRICTION
	bounce_factor = GameConfig.BALL_BOUNCE

func _physics_process(delta):
	# Mover la pelota
	var collision = move_and_collide(velocity * delta)

	if collision:
		handle_collision(collision)

	# Aplicar fricción DESPUÉS del movimiento
	velocity *= friction

	# Detener si va muy lento
	if velocity.length() < 5:
		velocity = Vector2.ZERO

	# Limitar velocidad máxima
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	
	if collider is CharacterBody2D and collider.has_method("get_input_direction"):
		handle_player_collision(collider, collision)
	else:
		handle_wall_collision(collision)

func handle_player_collision(player: CharacterBody2D, collision: KinematicCollision2D):
	last_hit_by = player
	last_hit_team = player.team

	var push_direction = collision.get_normal() * -1
	var push_force = player.current_push_force

	# Si el jugador está tacleando, mucha más fuerza
	if player.is_tackling:
		push_force *= 3.0

	var player_velocity_contribution = player.velocity * 0.8

	velocity = (push_direction * push_force) + player_velocity_contribution

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	ball_hit.emit(player)

func handle_wall_collision(collision: KinematicCollision2D):
	velocity = velocity.bounce(collision.get_normal()) * bounce_factor

func reset_position(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO
	last_hit_by = null
	last_hit_team = 0

func get_last_hit_team() -> int:
	return last_hit_team

func apply_force(force: Vector2):
	velocity += force
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
