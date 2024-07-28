extends Node2D

@export var regeneration_amount: int = 10


func _ready():
	#Como só vamos utilizar essa variável nessa parte do código, podemos chamá-la simplesmente dessa forma.
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amount)
		player.meat_collected.emit(regeneration_amount)
		queue_free()
	
	
