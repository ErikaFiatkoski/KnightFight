extends Node

@export var speed = 1.0

var enemy: Enemy
var sprite: AnimatedSprite2D


func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")


func _physics_process(delta: float) -> void:
	# Se deu GameOver, então todo o resto do código será ignorado
	if GameManager.is_game_over: return
	
	#Mover o inimigo na direção do player
	
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	var input_vector = difference.normalized() #input vector é um vetor2 que varia entre -1 e 1 em ambos os eixos
	enemy.velocity = input_vector * speed * 100.0
	
	enemy.move_and_slide()
	
		#Girar sprite:
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
