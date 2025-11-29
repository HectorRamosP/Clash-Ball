extends CharacterBody2D

# ===== IDENTIFICACIÓN DEL JUGADOR =====
@export var player_id: String = "player1"  # player1, player2, player3, player4
@export var team: int = 1  # 1 = izquierda (azul), 2 = derecha (rojo)

# ===== CONTROLES =====
@export_group("Controls")
@export var move_up: String = "ui_up"
@export var move_down: String = "ui_down"
@export var move_left: String = "ui_left"
@export var move_right: String = "ui_right"
@export var tackle_key: String = "ui_accept"  # Espacio o Enter

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

# ===== SISTEMA DE PODERES =====
var current_power: GameConfig.PowerType = GameConfig.PowerType.NONE
var power_timer: float = 0.0
var is_power_active: bool = false

# ===== TIMERS =====
var tackle_cooldown_timer: float = 0.0
var tackle_duration_timer: float = 0.0

# ===== REFERENCIAS =====
var ball: CharacterBody2D = null
var magneto_active: bool = false

# ===== SEÑALES =====
signal stamina_changed(new_stamina: float)
signal tackles_changed(remaining: int)
signal power_activated(power_type: GameConfig.PowerType)
signal power_ended()

func _ready():
	# Cargar estadísticas según la clase asignada
	load_class_stats()
	
	# Conectar señales del GameConfig
	GameConfig.power_granted.connect(_on_power_granted)

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
	
	# Sistema Magneto
	if magneto_active and ball:
		apply_magneto_effect()

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
	# Puede tacklear si tiene tacleos disponibles o el poder de tacleos ilimitados
	var has_tackles = remaining_tackles > 0 or (current_power == GameConfig.PowerType.UNLIMITED_TACKLES)
	return can_tackle and has_tackles and not is_tackling

func perform_tackle(direction: Vector2):
	if direction == Vector2.ZERO:
		direction = Vector2(1, 0) if team == 1 else Vector2(-1, 0)
	
	# Aplicar impulso del tacleo
	velocity = direction * GameConfig.TACKLE_FORCE
	
	# Estado de tacleo
	is_tackling = true
	tackle_duration_timer = GameConfig.TACKLE_DURATION
	
	# Decrementar tacleos si no tiene el poder activo
	if current_power != GameConfig.PowerType.UNLIMITED_TACKLES:
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
	
	# Timer del poder activo
	if power_timer > 0:
		power_timer -= delta
		if power_timer <= 0:
			deactivate_power()

func _on_power_granted(granted_player_id: String, power: GameConfig.PowerType):
	if granted_player_id == player_id:
		activate_power(power)

func activate_power(power: GameConfig.PowerType):
	# Desactivar poder anterior si existe
	if is_power_active:
		deactivate_power()
	
	current_power = power
	power_timer = GameConfig.get_power_duration(power)
	is_power_active = true
	
	# Aplicar efectos según el poder
	match power:
		GameConfig.PowerType.SUPER_SPEED:
			current_speed = base_speed * 1.5
		
		GameConfig.PowerType.SUPER_STRENGTH:
			current_push_force = base_push_force * 2.0
		
		GameConfig.PowerType.MAGNETO:
			magneto_active = true
		
		GameConfig.PowerType.UNLIMITED_TACKLES:
			pass  # Se maneja en can_use_tackle()
	
	power_activated.emit(power)
	print(player_id + " activó: " + GameConfig.get_power_name(power))

func deactivate_power():
	# Restaurar valores base
	match current_power:
		GameConfig.PowerType.SUPER_SPEED:
			current_speed = base_speed
		
		GameConfig.PowerType.SUPER_STRENGTH:
			current_push_force = base_push_force
		
		GameConfig.PowerType.MAGNETO:
			magneto_active = false
	
	current_power = GameConfig.PowerType.NONE
	is_power_active = false
	power_ended.emit()
	print(player_id + " poder terminado")

func apply_magneto_effect():
	if ball:
		# Atraer la pelota hacia el jugador suavemente
		var direction_to_ball = global_position.direction_to(ball.global_position)
		var distance = global_position.distance_to(ball.global_position)
		
		# Solo atraer si está cerca
		if distance < 150:
			var attraction_force = -direction_to_ball * 200.0
			ball.velocity += attraction_force * get_physics_process_delta_time()

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
