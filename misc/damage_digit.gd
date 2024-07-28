extends Node2D

var value: int = 0

func _ready():
	%Label.text = str(value) #transforma o valor contido em value (que era inteiro) em uma string

