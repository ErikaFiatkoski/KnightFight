extends Node

@export var mobs_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_per_minute: float = 30
@export var wave_duration: float = 20
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Se deu GameOver, então todo o resto do código será ignorado
	if GameManager.is_game_over: return
	
	time += delta
	
	#Dificuldade linear (linha verde)
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60.0)
	
	#Sistema de ondas (linha rosa)
	var sin_wave = sin((time * TAU) / wave_duration)
	
	# Parâmetros: variável a ser modificada, o menor valor possível atual, 
	# o maior valor possível atual, o menor valor possível que nós queremos, 
	# o maior valor possível que nós queremos
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
	#Aplicar dificuldade
	mobs_spawner.mobs_per_minute = spawn_rate
