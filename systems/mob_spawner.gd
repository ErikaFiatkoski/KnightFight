class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0 #Quantas criaturas serão criadas por minuto

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

#Variável utilizada como temporizador
var cooldown: float = 0.0


func _process(delta: float):
	
	# Se deu GameOver, então todo o resto do código será ignorado
	if GameManager.is_game_over: return
	
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0: return
	#---------------------------------------------------------------
	# Frequência: monstros por minuto
	# 60 monstros/min = 1 monstro por segundo
	# 120 monstros/min = 2 monstros por segundo
	# intervalo em segundos entre monstros => 60 / frequência
	# 60 / 60 = 1
	# 60 / 120 = 0.5
	# 60 / 30 = 2 
	var interval = 60.0 / mobs_per_minute
	
	cooldown = interval
	#---------------------------------------------------------------
	# Checar se o ponto é válido.
	#Perguntar pro jogo se esse ponto tem colisao
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.position = point
	parameters.collision_mask = 0b1001 #Vai poder colidir com as camadas 4 e 1
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty():return
	#---------------------------------------------------------------
	# Instanciar uma criatura aleatória
	# - Pegar criatura aleatoria
	var index = randi_range(0, creatures.size() -1)
	var creature_scene = creatures[index]
	# - Instanciar cena
	var creature = creature_scene.instantiate()
	# - Colocar em um ponto aleatório (utilizando o Path)
	creature.global_position = point
	# - Definir o parent
	get_parent().add_child(creature)
	
	

#Função que gera um valor aleatorio entre 0.0 e 1.1 e altera o atributo progress_ratio do path_follow_2d, retornando o valor da nova posição
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
