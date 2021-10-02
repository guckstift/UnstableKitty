extends Node2D

var Mouse = load("res://Mouse.tscn")

func _ready():
	randomize()
	spawn_mouse()

func spawn_mouse():
	var mouse = Mouse.instance()
	$Mice.add_child(mouse)
	mouse.gender = "f"
