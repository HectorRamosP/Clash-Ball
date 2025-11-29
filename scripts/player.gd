extends CharacterBody2D

# ===== IDENTIFICACIÓN DEL JUGADOR =====
@export var player_id: String = "player1"  # player1, player2, player3, player4
@export var team: int = 1  # 1 = izquierda (azul), 2 = derecha (rojo)

# ===== CONTROLES =====
var move_up: String = "p1_up"
var move_down: String = "p1_down"
var move_left: String = "p1_left"
var move_right: String = "p1_right"
var tackle_key: String = "p1_tackle"

# ===== ESTADÍSTICAS BASE =====
var player_class: GameConfig.PlayerClass = GameConfig.PlayerClass.SPRINTER
var base_speed: float = 400.0
var base_push_force: float = 300.0
var max_tackles: int = 2

# ===== ESTADO ACTUAL =====
var current_speed: float = 400.0
var current_push_force: float = 300.0
var stamina: float = GameConfig.MAX_STAMINA
var remaining_tackles: int = 2
var can_tackle: bool = true
var is_tackling: bool = false

# ===== TIMERS =====
var tackle_cooldown_timer: float = 0.0
var tackle_duration_timer: float = 0.0

# ===== REFERENCIAS =====
var ball: CharacterBody2D = null

# ===== SEÑALES =====
signal stamina_changed(new_stamina: float)
signal tackles_changed(remaining: int)

func _ready():
	# Mapear controles según player_id
	setup_controls()

	# Cargar estadísticas según la clase asignada
	load_class_stats()

func setup_controls():
	# Mapear automáticamente los controles según el ID del jugador
	var player_num = player_id.substr(6, 1)  # Extrae "1" de "player1"
	move_up = "p" + player_num + "_up"
	move_down = "p" + player_num + "_down"
	move_left = "p" + player_num + "_left"
	move_right = "p" + player_num + "_right"
	tackle_key = "p" + player_num + "_tackle"

func load_class_stats():
	# Obtener la clase del jugador desde GameConfig
	if player_id in GameConfig.player_classes:
		player_class = GameConfig.player_classes[player_id]
	
	# Cargar stats base
	var stats = GameConfig.get_class_stats(player_class)
	base_speed = stats.speed
	base_push_force = stats.push_force
	max_tackles = stats.initial_tackles
	
	# Inicializar valores actuales
	current_speed = base_speed
	current_push_force = base_push_force
	remaining_tackles = max_tackles

func _physics_process(delta):
	# Actualizar timers
	update_timers(delta)

	# Obtener input del jugador
	var input_dir = get_input_direction()

	# Procesar tacleo
	if Input.is_action_just_pressed(tackle_key) and can_use_tackle():
		perform_tackle(input_dir)

	# Movimiento normal (si no está tacleando)
	if not is_tackling:
		handle_movement(input_dir, delta)
	else:
		# Durante el tacleo, mantener el impulso
		move_and_slide()

	# Actualizar estamina
	update_stamina(input_dir, delta)

	# Detectar colisiones con otros jugadores para empujar
	handle_player_collisions()

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed(move_up):
		direction.y -= 1
	if Input.is_action_pressed(move_down):
		direction.y += 1
	if Input.is_action_pressed(move_left):
		direction.x -= 1
	if Input.is_action_pressed(move_right):
		direction.x += 1
	
	return direction.normalized()

func handle_movement(direction: Vector2, delta: float):
	if direction != Vector2.ZERO:
		# Calcular velocidad considerando estamina
		var speed_multiplier = 1.0
		if stamina <= 0:
			speed_multiplier = 0.5  # 50% velocidad sin estamina
		
		velocity = direction * current_speed * speed_multiplier
	else:
		# Aplicar fricción cuando no hay input
		velocity = velocity * GameConfig.PLAYER_FRICTION
	
	move_and_slide()

func update_stamina(direction: Vector2, delta: float):
	if direction != Vector2.ZERO:
		# Drenar estamina al moverse
		stamina -= GameConfig.STAMINA_DRAIN_RATE * delta
		stamina = max(0, stamina)
	else:
		# Regenerar estamina al no moverse
		stamina += GameConfig.STAMINA_REGEN_RATE * delta
		stamina = min(GameConfig.MAX_STAMINA, stamina)
	
	stamina_changed.emit(stamina)

func can_use_tackle() -> bool:
	# Puede tacklear si tiene tacleos disponibles
	return can_tackle and remaining_tackles > 0 and not is_tackling

func perform_tackle(direction: Vector2):
	if direction == Vector2.ZERO:
		direction = Vector2(1, 0) if team == 1 else Vector2(-1, 0)
	
	# Aplicar impulso del tacleo
	velocity = direction * GameConfig.TACKLE_FORCE
	
	# Estado de tacleo
	is_tackling = true
	tackle_duration_timer = GameConfig.TACKLE_DURATION

	# Decrementar tacleos
	remaining_tackles -= 1
	tackles_changed.emit(remaining_tackles)

	# Cooldown del tacleo
	can_tackle = false
	tackle_cooldown_timer = GameConfig.TACKLE_COOLDOWN
	
	# Aquí podrías añadir efectos visuales o sonidos
	print(player_id + " realizó un tacleo!")

func update_timers(delta: float):
	# Timer de duración del tacleo
	if tackle_duration_timer > 0:
		tackle_duration_timer -= delta
		if tackle_duration_timer <= 0:
			is_tackling = false
	
	# Timer de cooldown del tacleo
	if tackle_cooldown_timer > 0:
		tackle_cooldown_timer -= delta
		if tackle_cooldown_timer <= 0:
			can_tackle = true

func reset_for_goal():
	# Restaurar tacleos
	remaining_tackles = max_tackles
	tackles_changed.emit(remaining_tackles)
	
	# Restaurar estamina
	stamina = GameConfig.MAX_STAMINA
	stamina_changed.emit(stamina)
	
	# Resetear estado
	is_tackling = false
	can_tackle = true
	velocity = Vector2.ZERO

func set_ball_reference(ball_node: CharacterBody2D):
	ball = ball_node

func handle_player_collisions():
	# Detectar colisiones con otros jugadores
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Si chocamos con otro jugador
		if collider is CharacterBody2D and collider.has_method("get_input_direction"):
			var push_direction = collision.get_normal() * -1
			var push_strength = current_push_force

			# Si está tacleando, el empuje es mucho mayor
			if is_tackling:
				push_strength *= 2.5

			# Aplicar empuje al otro jugador (CharacterBody2D siempre tiene velocity)
			collider.velocity += push_direction * push_strength * get_physics_process_delta_time()
