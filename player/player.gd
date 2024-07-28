class_name Player
extends CharacterBody2D

#VARIÁVEIS EXPORTADAS E ONREADY:
@export_category("Movement")
@export var speed: float = 3

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar
#-------------------------------------------------------------------------------
#OUTRAS VARIÁVEIS
var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

#-------------------------------------------------------------------------------
signal meat_collected(value:int)


#FUNÇÕES

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): 
		GameManager.meat_counter += 1
		)

func _process(delta: float) -> void:
	
	GameManager.player_position = position
	
	read_input()
	
	#Processar o ataque
	update_attack_cooldown(delta)

	if Input.is_action_just_pressed("attack"):
		attack_side()
	
	if Input.is_action_just_pressed("attack_up"):
		attack_up()
		
	if Input.is_action_just_pressed("attack_down"):
		attack_down()
		
		
		
	#Processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	update_hitbox_detection(delta)
	
	#RITUAL
	update_ritual(delta)
	
	#Atualizar barra de vida
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	
func _physics_process(delta: float) -> void:
	#Modificar a velocidade
	var target_velocity = input_vector * speed * 100
	
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	#movimentar o personagem
	move_and_slide()
	

func update_attack_cooldown(delta: float) -> void:
	#Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
			
func update_ritual(delta: float) -> void:
	#Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	#Criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)



func read_input() -> void:
	#Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#Apagar deadzone do input vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	#Atualizar o is_running:
	was_running = is_running #Eu estava correndo?
	is_running = not input_vector.is_zero_approx() #Verifica se o valor do input não é zero (se for zero, então o personagem esta correndo. Se for zero, então o personagem NÃO está correndo)
	

func play_run_idle_animation() -> void:
	#Tocar animação:
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
		#Girar sprite:
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
	

func attack_side() -> void:
	if is_attacking:
		return
	# attack_side_1
	# attack_side_2
	#Tocar animação
	animation_player.play("attack_side_1")
	
	#Configurar temporizador
	attack_cooldown = 0.6
	
	#Marcar ataque
	is_attacking = true
	

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies() #Acessa todos os corpos dentro da area de ataque
	for body in bodies: #Para cada corpo dentro da area de ataque, nós testamos se esse corpo é um inimigo (pois não queremos aingir o cenario)
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized() #Angulo do personagem em relação ao inimigo
			var attack_diretion: Vector2
			if sprite.flip_h:
				attack_diretion = Vector2.LEFT 
			else:
				attack_diretion = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_diretion)
			
			if dot_product >= 0.3:
				print("Dot: ", dot_product)
				#Chamar a função damage com "sword_damage" como primeiro parâmetro
				enemy.damage(sword_damage)
	
	
func attack_up() -> void:
	if is_attacking:
		return
	#Tocar animação	
	animation_player.play("attack_up_1")
	#Configurar temporizador
	attack_cooldown = 0.6
	#Marcar ataque
	is_attacking = true

func attack_down() -> void:
	#Tocar animação	
	animation_player.play("attack_down_1")
	#Configurar temporizador
	attack_cooldown = 0.6
	#Marcar ataque
	is_attacking = true

func 	update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta #A todo frame, a gente tira o tempo do frame
	if hitbox_cooldown > 0: return #Se o valor do hitbox for maior que 0, a função não irá executar o resto do código.
	
	# Frequência (2x por segundo). A cada dois segundos, o valor de hitbox_cooldown é atualizado para 0.5, ou seja, maior que 0. 
	hitbox_cooldown = 0.5 	#Logo, o codigo abaixo será ignorado, ate que a variável seja menor ou igual a 0 novamente.   
							#Esta linha serve como contador, pois faz com que a função não seja executada a todo instante, mas sim a cada dois segundos.
	
	
	#Detectar inimigos na HitboxArea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
	

func damage(amount: int) -> void:
	
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health)
	
	#Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#Processar morte
	if health <= 0:
		die()
		

func die() -> void:
	
	GameManager.end_game()
	
	#Verifica se temos algum arquivo armazenado na variável e, se sim, o instancia
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	queue_free()
	
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health)
	return health











